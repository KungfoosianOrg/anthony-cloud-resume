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

variable "lambda_role_name" {
  type = string
  description = "Name for Lambda execution role"
  default = "VisitorCounterLambdaExecutionRole"
}

variable "source_relative_path" {
  description = "Path to local file or directory containing your Lambda source code, relative to where 'terraform apply' is run"
  type = string
}

variable "aws_cicd_role-name" {
  description = "Name of AWS role for CI/CD process to assume to interact with this module"
  type = string
}


###################
# Visitor Counter #
###################

variable "api_trigger_method" {
  type = string
  description = "HTTP method to trigger API, leave blank for ANY"
  default = "ANY"
}

variable "api_route_key" {
  type = string
  description = "route to trigger API, leave blank for root path. E.g: my-api -> /my-api"
  default = ""
}