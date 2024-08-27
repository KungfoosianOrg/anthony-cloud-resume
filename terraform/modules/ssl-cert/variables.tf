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

variable "route53_hosted_zone_id" {
  type        = string
  description = "ID of AWS Route53 hosted zone for your domain"
  default     = ""
}