data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "visitor_counter-lambda" {
  log_group_class   = "STANDARD"
  name              = var.lambda-log_group-name
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "visitor_counter-api_gw" {
  log_group_class   = "STANDARD"
  name              = var.api_gw-log_group-name
  retention_in_days = 3
}


# section - API Gateway (SAMVisitorCounterApiGw in CloudFormation SAM)
resource "aws_apigatewayv2_api" "visitor_counter-api" {
  description   = "API Gateway to trigger Lambda to perform read/write on DynamoDB"
  name          = "visitor_counter-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_methods = ["POST"]
    allow_origins = ["*"] // TODO (later): change to website URL and subdomain
    max_age       = 0
  }

  # target = aws_lambda_function.visitor_counter.arn # leave this in would interfere with our own api $default stage resource
}

resource "aws_apigatewayv2_deployment" "visitor_counter" {
  api_id = aws_apigatewayv2_api.visitor_counter-api.id

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.visitor_counter-lambda),
      jsonencode(aws_apigatewayv2_route.visitor_counter-api_invoke_route)
    ])))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# https://github.com/hashicorp/terraform-provider-aws/issues/24852
resource "aws_apigatewayv2_stage" "visitor_counter" {
  api_id      = aws_apigatewayv2_api.visitor_counter-api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.visitor_counter-api_gw.arn

    format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"
  }
}

resource "aws_apigatewayv2_integration" "visitor_counter-lambda" {
  api_id                 = aws_apigatewayv2_api.visitor_counter-api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.visitor_counter.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "visitor_counter-api_invoke_route" {
  api_id             = aws_apigatewayv2_api.visitor_counter-api.id
  route_key          = "${var.api_trigger_method != "" ? var.api_trigger_method : "ANY"} /${var.api_route_key}"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.visitor_counter-lambda.id}"
}

resource "aws_lambda_permission" "api_gw-lambda_access_permission" {
  action        = "lambda:InvokeFunction"
  # function_name = aws_lambda_function.visitor_counter.function_name
  function_name = aws_lambda_function.visitor_counter.arn
  principal     = "apigateway.amazonaws.com"

  # allows all stages of API deployment (first *) to call the Lambda, and specifies exact method or route key defined for triggering of Lambda 
  source_arn    = "${aws_apigatewayv2_api.visitor_counter-api.execution_arn}/*/${var.api_trigger_method != "" ? var.api_trigger_method : "ANY"}/${var.api_route_key != "" ? var.api_route_key : "*"}"
}
### END section ###


# section - Lambda function
# converts the folder to a zip package at specified path
data "archive_file" "visitor_counter-package" {
  type = "zip"

  # path.module gets the system path to the folder containing this module
  source_dir = "${path.module}/../../../aws/visitorCounter"

  output_path = "${path.module}/../../../out/visitorCounter.zip"
}

resource "aws_lambda_function" "visitor_counter" {
  function_name = var.lambda_function_name

  role = aws_iam_role.visitor_counter-lambda_function-execution_role.arn

  description = "Lambda backend code for visitor counter, handles HTTP POST requests to increase a website visitor counter"

  environment {
    variables = {
      DDB_TABLE_REGION = var.aws_region

      DDB_TABLE_ARN = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.visitor_counter-table.id}"
    }
  }

  # uses the zip package output from archive_file above
  filename = "${path.module}/../../../out/visitorCounter.zip"

  package_type = "Zip"

  runtime = "python3.9"

  handler = "lambda_function.lambda_handler"

  # might not need to worry about Events section, since we can point api gateway to this

  logging_config {
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_format            = "JSON"
    log_group             = var.lambda-log_group-name
  }
}

data "aws_iam_policy_document" "lambda-assume_role" {
  statement {
    effect = "Allow"

    # Why principal is defined this way? https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#principals
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "visitor_counter-lambda_function-execution_role" {
  name = "VisitorCounterLambdaExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume_role.json
}


data "aws_iam_policy_document" "visitor_counter-lambda-policies" {
  version = "2012-10-17"

  # permission policies
  statement {
    sid    = "VisitorCounterDDBPermissions"
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable"
    ]

    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.visitor_counter-table.id}",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.visitor_counter-table.id}/index/*"
    ]
  }

}

resource "aws_iam_policy" "lambda-execution_policy" {
  policy = data.aws_iam_policy_document.visitor_counter-lambda-policies.json
}

resource "aws_iam_role_policy_attachment" "lambda-execution_policy_attach" {
  role = aws_iam_role.visitor_counter-lambda_function-execution_role.name

  policy_arn = aws_iam_policy.lambda-execution_policy.arn
}

# attach LambdaBasicExecutionRole so Lambda can log
resource "aws_iam_role_policy_attachment" "aws_managed_policies" {
  role       = aws_iam_role.visitor_counter-lambda_function-execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# END section


# section - DynamoDB table
resource "aws_dynamodb_table" "visitor_counter-table" {
  name         = "VisitorCounterTable"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}
# END section