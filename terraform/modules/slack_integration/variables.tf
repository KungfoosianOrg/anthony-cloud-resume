variable "aws_region" {
  description = "Needs to be us-east-1 since AWS creates and validates SSL cert"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}

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

variable "slack_webhook_url" {
  description = "URL for Slack webhook"
  type        = string
  default     = ""
}