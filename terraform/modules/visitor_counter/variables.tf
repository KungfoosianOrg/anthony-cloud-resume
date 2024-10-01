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
  default = "lambda/VisitorCounter"
}

variable "api_gw-log_group-name" {
  type    = string
  default = "apigateway/VisitorCounter"
}

variable "lambda_function_name" {
  type    = string
  default = "VisitorCounterLambda"
}

variable "api_trigger_method" {
  type = string
  description = "HTTP method to trigger API, leave blank for ANY"
  default = ""
}

variable "api_route_key" {
  type = string
  description = "route to trigger API, leave blank for root path. E.g: my-api -> /my-api"
  default = ""
}