variable "aws_region" {
  description = "Needs to be us-east-1 since AWS creates and validates SSL cert"
  type    = string
  default = "us-east-1"
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
  description = "ID of Route53 hosted zone for your domain. Leave blank to have one created for you. NOTE: you'll need to delete zone manually if not used anymore, this is to keep costs low since you get charged per zone creationn"
  default     = ""
}

variable "notification_email" {
  type = string
  description = "Email to send CloudWatch alarms to"
  default = ""
}

# might not even need if making the whole app with SAM in one place
# variable "slack_webhook-ssm_key_arn" {
#   type = string
#   description = "AWS ARN of Slack webhook SSM SecureString parameter for Slack integration"
#   default = ""
# }
# variable "kms_decrypt_key_arn" {
#   type = string
#   description = "AWS ARN of KMS decrypt key for slack_webhook-ssm_key_arn"
#   default = ""
# }