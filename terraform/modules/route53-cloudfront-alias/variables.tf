variable "fqdns" {
  type        = list(string)
  description = "List of subdomains you want to route traffic for, including the domain"
  default = []
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "ID of AWS Route53 hosted zone for your domain"
  default = ""
}

variable "cloudfront_distribution_fqdn" {
  type = string
  description = "FQDN of the created CloudFront distribution"
  default = ""
}

variable "default_cloudfront_hostedzone" {
  type = string
  description = "AWS-provided, hosted zone ID for all CloudFront distributions. DO NOT CHANGE UNLESS NECESSARY"
  default = "Z2FDTNDATAQYW2"
}

variable "aws_region" {
  type = string
  default = ""
}