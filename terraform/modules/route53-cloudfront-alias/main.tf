terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}


# Creating IPv4 and IPv6 alias records for the domain itself
resource "aws_route53_record" "ip4_domain_alias_record" {
  zone_id = var.route53_hosted_zone_id
  name    = var.registered_domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_fqdn
    zone_id                = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ip6_domain_alias_record" {
  zone_id = var.route53_hosted_zone_id
  name    = var.registered_domain_name
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_distribution_fqdn
    zone_id                = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}

#Creating IPv4 and IPv6 alias records for the subdomains
resource "aws_route53_record" "ip4_subdomain_alias_records" {
  for_each = toset(var.subdomains)

  zone_id = var.route53_hosted_zone_id
  name    = "${each.value}.${var.registered_domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_fqdn
    zone_id                = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ip6_subdomain_alias_records" {
  for_each = toset(var.subdomains)

  zone_id = var.route53_hosted_zone_id
  name    = "${each.value}.${var.registered_domain_name}"
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_distribution_fqdn
    zone_id                = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}