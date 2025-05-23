variable "registered_domain_name" {
  type        = string
  description = "The domain name that you registered and want to route traffic for"
  nullable    = false
}

variable "subdomains" {
  type        = list(string)
  description = "List of subdomains you want to route traffic for, Usage: [\"www\",\"test\"] for FQDNs: www.example.com, test.example.com"
  default     = []
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "ID of AWS Route53 hosted zone for your domain. If blank, one will be created automatically"
  default     = ""
}

variable "apigw_endpoint_url" {
  type        = string
  description = "URL of API Gateway endpoint, format: <endpoint_id>.execute-api.<aws_region>.amazonaws.com[/<path>] . FIRST TIME SETUP: leave default value"
  default     = "none"
}

variable "ghactions_aws_role_name" {
  type        = string
  description = "Name of role for GitHub Actions"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of ACM certificate for the custom domain (if custom domain name parameter is defined)"
  default     = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_cicd_role-name" {
  type = string
  description = "Name of AWS IAM role for CI/CD process to assume for interacting with resources of this module"
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

variable "is_prod_build" {
  type        = bool
  description = "Sets up build for production, disables route53 zone creation. Default: true. Set to false for testing"
  default     = true
}