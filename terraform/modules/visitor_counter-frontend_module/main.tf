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
# end

module "visitor_counter-lambda_function" {
  
}

resource "aws_iam_role" "visitor_counter-lambda_function-iam_role" {
  name = "IAM role for visitor counter lambda"

  assume_role_policy = 
}

/*name = "iam_for_lambda_usage"

  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
    EOF

  inline_policy {
    name = "dynamodb_access"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": [
                "dynamodb:List*",
                "dynamodb:DescribeReservedCapacity*",
                "dynamodb:DescribeLimits",
                "dynamodb:DescribeTimeToLive"
            ],
            "Resource": "*",
            "Effect": "Allow"
            },
            {
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:CreateTable",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": [
                "${aws_dynamodb_table.book-reviews-ddb-table.arn}"
            ],
            "Effect": "Allow"
            }
        ]
    })
  }
*/

resource "aws_dynamodb_table" "visitor_counter-table" {}