terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}


data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "visitor_counter-lambda" {
  log_group_class = "STANDARD"
  name = var.lambda-log_group-name
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "visitor_counter-api_gw" {
  log_group_class = "STANDARD"
  name = var.api_gw-log_group-name
  retention_in_days = 3
}


# section - API Gateway (SAMVisitorCounterApiGw in CloudFormation SAM)
resource "aws_apigatewayv2_api" "visitor_counter-api" {
  description = "API Gateway to trigger Lambda to perform read/write on DynamoDB"
  name = "visitor_counter-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_methods = [ "POST" ]
    allow_origins = [ "*" ] // TODO (later): change to website URL and subdomain
    max_age = 0
  }

  target = aws_lambda_function.visitor_counter.arn
}

resource "aws_apigatewayv2_stage" "visitor_counter" {
  api_id = aws_apigatewayv2_api.visitor_counter-api.id
  name = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.visitor_counter-api_gw.arn

    format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"
  }
}

resource "aws_apigatewayv2_integration" "publish_book_review_api" {}

resource "aws_apigatewayv2_route" "publish_book_review_route" {}

resource "aws_lambda_permission" "api_gw" {}
### END section ###


# section - Lambda function
data "archive_file" "visitor_counter-package" {
  type = "zip"

  source_dir = "../../../aws/visitorCounter"

  output_path = "../../../out/visitorCounter.zip"
}

resource "aws_lambda_function" "visitor_counter" {
  function_name = "VisitorCounterLambda"

  role = aws_iam_role.visitor_counter-lambda_function-execution_role.arn

  description = "Lambda backend code for visitor counter, handles HTTP POST requests to increase a website visitor counter"

  environment {
    variables = {
      DDB_TABLE_REGION = var.aws_region

      DDB_TABLE_ARN = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.visitor_counter-table.id}"
    }
  }

  filename = "../../../out/visitorCounter.zip"

  package_type = "Zip"

  runtime = "python3.9"

  handler = "lambda_function.lambda_handler"

  # might not need to worry about Events section, since we can point api gateway to this

  logging_config {
    application_log_level = "INFO"
    system_log_level = "INFO"
    log_format = "JSON"
    log_group = var.lambda-log_group-name
  }
}

data "aws_iam_policy_document" "visitor_counter-lambda-policies" {
  version = "2012-10-17"

  statement {
    sid = "trustPolicy"
    actions = [ "sts:AssumeRole" ]

    # Why principal is defined this way? https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#principals
    principals {
      type = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }

  # permission policies
  statement {
    sid = "VisitorCounterDDBPermissions"
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

  # TODO: the rest of Lambda execution permissions
  statement {
    sid = "CopiedAWSLambdaBasicExecutionRole"
    effect = "Allow"

    actions = [ 
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [ "*" ]
  }

}


resource "aws_iam_role" "visitor_counter-lambda_function-execution_role" {
  name = "IAM role for visitor counter lambda"

  assume_role_policy = data.aws_iam_policy_document.visitor_counter-lambda-policies.json
}

# END section


# section - DynamoDB table
resource "aws_dynamodb_table" "visitor_counter-table" {
  name =  "VisitorCounterTable"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
# END section