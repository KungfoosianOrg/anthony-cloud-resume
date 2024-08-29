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

variable "cloudfront_distribution_fqdn" {
  type        = string
  description = "FQDN of the created CloudFront distribution"
  default     = ""
}

variable "default_cloudfront_hostedzone" {
  type        = string
  description = "CAUTION !!! AWS-provided, hosted zone ID for all CloudFront distributions. DO NOT CHANGE UNLESS NECESSARY"
  default     = "Z2FDTNDATAQYW2"
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = ""
}