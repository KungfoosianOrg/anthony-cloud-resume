################
# General Info #
################

variable "aws_region" {
  description = "Needs to be us-east-1 since AWS creates and validates SSL cert"
  type        = string
  default     = "us-east-1"
}

# variable "aws_profile" {
#   type    = string
#   default = ""
# }

# variable "aws_role_arn" {
#   type = string
#   description = "ARN of AWS IAM role for Terraform to assume in order to create the infrastructure"
#   default = "aws:arn:change:me"
# }

variable "lambda-log_group-name" {
  type    = string
  default = "lambda/SendSlackMessage"
}

variable "api_gw-log_group-name" {
  type    = string
  default = "apigateway/SendSlackMessage"
}

variable "lambda_function_name" {
  type    = string
  default = "SendSlackMessageLambda"
}

variable "source_relative_path" {
  description = "Path to local file or directory containing your Lambda source code, relative to where 'terraform apply' is run"
  type = string
  default = ""
}

variable "lambda_role_name" {
  description = "Name for lambda execution role"
  type = string
  default = "SlackIntegrationLambdaExecutionRole"
  
}

variable "aws_cicd_role-name" {
  description = "Name of AWS role for CI/CD process to assume to interact with this module"
  type = string
}


#####################
# Slack Integration #
#####################

variable "slack_webhook_url" {
  description = "URL for Slack webhook"
  type        = string
  default     = ""
}
