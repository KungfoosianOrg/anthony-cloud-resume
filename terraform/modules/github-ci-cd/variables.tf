variable "github_repo_full_name" {
  description = "Full path of GitHub repository, format: <owner>/<repository name>"
  type        = string
  default     = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

# variable "aws_profile" {
#   type    = string
#   default = ""
# }

variable "aws_role_arn" {
  type = string
  description = "ARN of AWS IAM role for Terraform to assume in order to create the infrastructure"
  default = "aws:arn:change:me"
}