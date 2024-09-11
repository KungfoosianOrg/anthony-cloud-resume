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
  name = "lambda/VisitorCounter"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "visitor_counter-api_gw" {
  log_group_class = "STANDARD"
  name = "apigateway/VisitorCounter"
  retention_in_days = 3
}


# section - API Gateway (SAMVisitorCounterApiGw in CloudFormation SAM)
resource "aws_apigatewayv2_api" "lambda" {}

resource "aws_apigatewayv2_stage" "lambda" {}

resource "aws_apigatewayv2_integration" "publish_book_review_api" {}

resource "aws_apigatewayv2_route" "publish_book_review_route" {}

resource "aws_lambda_permission" "api_gw" {}
### END section ###


# section - Lambda function
module "visitor_counter-lambda_function" {

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


resource "aws_iam_role" "visitor_counter-lambda_function-iam_role" {
  name = "IAM role for visitor counter lambda"

  assume_role_policy = data.aws_iam_policy_document.visitor_counter-lambda-policies.json
}

# END section


resource "aws_dynamodb_table" "visitor_counter-table" {
  name =  "VisitorCounterTable"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}