variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = ""
}

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

variable "SAM_stack_name" {
  description = "Name of SAM stack"
  type        = string
  default     = ""
}


variable "github_repo_name_full" {
  description = "Full path of GitHub repository, format: <owner>/<repository name>"
  type        = string
  default     = ""
}


variable "apigw_endpoint_url" {
  type        = string
  description = "URL of API Gateway endpoint, format: <endpoint_id>.execute-api.<aws_region>.amazonaws.com[/<path>] . FIRST TIME SETUP: leave default value"
  default     = ""
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "ID of Route53 hosted zone for your domain. Might be better to manually create one to avoid being charged for multiple if zone creation is automated"
  default     = ""
}


# variable "ghactions_aws_role_arn" {
#   type        = string
#   description = "ARN of role for GitHub Actions"
#   default     = ""
# }

# variable "acm_certificate_arn" {
#   type        = string
#   description = "ARN of ACM certificate for the custom domain (if custom domain name parameter is defined)"
#   default     = ""
# }