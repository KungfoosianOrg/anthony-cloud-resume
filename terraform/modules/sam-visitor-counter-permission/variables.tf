variable "ghactions_aws_role_arn" {
  type        = string
  description = "ARN of role for GitHub Actions"
  default     = ""
}

variable "cfdistro_response_headers_policy_id" {
  type = string
  description = "CloudFront distribution's response header's id"
  default = ""
}

variable "SAM_stack_name" {
  type        = string
  description = "Name of SAM stack"
  default     = "my-sam-stack"
}

variable "aws_region" {
  type        = string
  description = "AWS region to create stack in. Must be us-east-1 for SSL to work"
  default     = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}