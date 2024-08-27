variable "github_repo_name_full" {
  type        = string
  description = "Name of GitHub repository, full path, e.g: OwnerAccount/RepoName"
  nullable    = false
}

variable "aws_oidc_provider_arn" {
  type        = string
  description = "ARN for the GitHub OIDC Provider. Leave blank and one will be created automatically"
  default     = ""
}

variable "registered_domain_name" {
  type        = string
  description = "The domain name that you registered and want to route traffic for"
  nullable    = false
}

variable "fqdns" {
  type        = list(string)
  description = "List of subdomains you want to route traffic for, including the domain"
  nullable    = false
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "ID of AWS Route53 hosted zone for your domain"
  nullable    = false
}

variable "SAM_stack_name" {
  type        = string
  description = "Name of SAM stack"
  default     = "my-sam-stack"
}

variable "apigw_endpoint_url" {
  type        = string
  description = "URL of AWS API Gateway endpoint, in format: <endpoint_id>.execute-api.<aws_region>.amazonaws.com[/<path>] . FIRST TIME SETUP: leave default value"
  default     = "none"
}

variable "aws_region" {
  type        = string
  description = "AWS region to create stack in. Must be us-east-1 for SSL to work"
  default     = "us-east-1"
}