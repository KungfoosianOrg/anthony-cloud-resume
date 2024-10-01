variable "ghactions_aws_role_arn" {
  type        = string
  description = "ARN of role for GitHub Actions"
  default     = ""
}

variable "SAM_stack_name" {
  type        = string
  description = "Name of SAM stack"
  default     = ""
}

variable "cfdistro_response_headers_policy_id" {
  type        = string
  description = "CloudFront distribution's response header's id"
  default     = null
}

variable "cfdistro_oac_id" {
  type        = string
  description = "Id of CloudFront distribution's Origin Access Control (OAC)"
  default     = null
}

variable "cfdistro_id" {
  type        = string
  description = "Id of CloudFront distribution"
  default     = null
}


variable "aws_region" {
  type        = string
  description = "AWS region to create stack in. Must be us-east-1 for SSL to work"
  default     = "us-east-1"
}

# variable "aws_profile" {
#   type    = string
#   default = null
# }

variable "aws_role_arn" {
  type = string
  description = "ARN of AWS IAM role for Terraform to assume in order to create the infrastructure"
  default = "aws:arn:change:me"
}