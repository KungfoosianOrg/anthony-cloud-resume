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
  log_group_class   = "STANDARD"
  name              = var.lambda-log_group-name
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "visitor_counter-api_gw" {
  log_group_class   = "STANDARD"
  name              = var.api_gw-log_group-name
  retention_in_days = 3
}


# section - Lambda function
# creates a securestring parameter for storing Slack's webhook URL
data "aws_kms_alias" "default_ssm_key" {
  name = "alias/aws/ssm"
}

resource "aws_ssm_parameter" "slack_webhook_url" {
  name = "SLACK_WEBHOOK_URL"
  type = "SecureString"
  data_type = "text"
  description = "Slack webhook URL"
  key_id = data.aws_kms_alias.default_ssm_key.arn
  value = var.slack_webhook_url
}


# converts the folder to a zip package at specified path
data "archive_file" "visitor_counter-package" {
  type = "zip"

  source_dir = "../../../aws/sendSlackMessage"

  output_path = "../../../out/sendSlackMessage.zip"
}

resource "aws_lambda_function" "slack_integration" {
  function_name = var.lambda_function_name

  role = aws_iam_role.visitor_counter-lambda_function-execution_role.arn

  description = "Integration with Slack, triggered by SNS"

  # uses the zip package output from archive_file above
  filename = "../../../out/sendSlackMessage.zip"

  package_type = "Zip"

  runtime = "python3.9"

  handler = "lambda_function.lambda_handler"

  logging_config {
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_format            = "JSON"
    log_group             = var.lambda-log_group-name
  }
}

data "aws_iam_policy_document" "visitor_counter-lambda-policies" {
  version = "2012-10-17"

  statement {
    sid     = "trustPolicy"
    actions = ["sts:AssumeRole"]

    # Why principal is defined this way? https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#principals
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }

  # permission policies
  statement {
    sid    = "CopiedAWSLambdaBasicExecutionRole"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid = "LambdaAccessSsmParam"
    effect = "Allow"

    actions = [ "ssm:GetParameter" ]

    resources = [ aws_ssm_parameter.slack_webhook_url.arn ]
  }

  statement {
    sid = "LambdaAccessSsmParamDecryptKey"
    effect = "Allow"

    actions = [ "kms:Decrypt" ]

    resources = [ data.aws_kms_alias.default_ssm_key.arn ]
  }

}


resource "aws_iam_role" "visitor_counter-lambda_function-execution_role" {
  name = "VisitorCounterLambdaExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.visitor_counter-lambda-policies.json
}

# END section