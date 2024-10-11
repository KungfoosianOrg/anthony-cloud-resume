variable "aws_region" {
  description = "Needs to be us-east-1 since AWS creates and validates SSL cert"
  type        = string
  default     = "us-east-1"
}

variable "registered_domain_name" {
  type        = string
  description = "The domain name that you registered and want to route traffic for"
  nullable    = false
}

variable "subdomains" {
  type        = list(string)
  description = "List of subdomains you want to route traffic for, Usage: [\"www\",\"test\"] for FQDNs: www.example.com, test.example.com"
  default     = ["www"]
}

variable "github_repo_name_full" {
  description = "Full path of GitHub repository, format: <owner>/<repository name>"
  type        = string
  default     = ""
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "ID of Route53 hosted zone for your domain. Leave blank to have one created for you. NOTE: you'll need to delete zone manually if not used anymore, this is to keep costs low since you get charged per zone creationn"
  default     = ""
}

variable "notification_email" {
  description = "Email to send SNS notifications topic"
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "URL for Slack webhook"
  type        = string
  default     = ""
}

variable "visitor_counter-api_trigger_method" {
  type        = string
  description = "HTTP method to trigger visitor counter API, leave blank for ANY"
  default     = ""
}

variable "visitor_counter-api_route_key" {
  type        = string
  description = "route to trigger visitor counter API, leave blank for root path. E.g: my-api -> /my-api"
  default     = ""
}

variable "lambda_placeholder-source_relative_path" {
  type        = string
  description = "relative path to placeholder code for Lambda"
  default     = "placeholder/lambda"
}