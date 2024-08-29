# This module:
#   1. (depends) Creates a Route53 hosted zone for a custom domain
#   2. Creates IPv4 (A) and IPv6 (AAAA) alias records for the domain (and any subdomains), pointing to a CloudFront distribution
#   3. Validates SSL certificate for the custom domain with the Route53 hosted zone
#
#
# Optional parameters:
#   + route53_hosted_zone_id


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

##### PART 1 #####

# Checks if route53_hosted_zone_id is defined:
#   yes: ignore this resource creation
#   no : create hosted zone
resource "aws_route53_zone" "primary" {
  count = var.route53_hosted_zone_id == "" ? 1 : 0

  name = var.registered_domain_name
}
##### END PART #####


##### PART 2 #####

# Creating IPv4 and IPv6 alias records for the domain itself
resource "aws_route53_record" "ip4_domain_alias_record" {
  allow_overwrite = true
  zone_id = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary.zone_id : var.route53_hosted_zone_id
  name    = var.registered_domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_fqdn
    zone_id                = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ip6_domain_alias_record" {
  allow_overwrite = true
  zone_id = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary.zone_id : var.route53_hosted_zone_id
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

  allow_overwrite = true
  zone_id = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary.zone_id : var.route53_hosted_zone_id
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

  allow_overwrite = true
  zone_id = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary.zone_id : var.route53_hosted_zone_id
  name    = "${each.value}.${var.registered_domain_name}"
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_distribution_fqdn
    zone_id                = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}

##### END PART #####


##### PART 3 #####

# create the SSL cert
resource "aws_acm_certificate" "ssl_cert" {
  domain_name               = var.registered_domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.registered_domain_name}"]

  validation_option {
    domain_name       = var.registered_domain_name
    validation_domain = var.registered_domain_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create the SSL cert validation
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.ssl_cert.arn
}

# create DNS records for certificate validation
resource "aws_route53_record" "ssl_cert_validation_records" {
  # (from innermost > outward) gets all the domain_validation_options objects from the ssl_cert resource,
  # maps each to an object with the key being each option's domain_name, then loop through them w/ for_each to create each ssl_validation_record resource
  #   NOTE: This way is recommended for resources whose values you won't know until creation
  for_each = tomap({
    for domain_validation_option in aws_acm_certificate.ssl_cert.domain_validation_options : domain_validation_option.domain_name => {
      name = domain_validation_option.resource_record_name
      record = domain_validation_option.resource_record_value
      type = domain_validation_option.resource_record_type
    }
  })

  allow_overwrite = true
  zone_id         = var.route53_hosted_zone_id
  ttl             = 300
  type            = each.value.type
  name            = each.value.name
  records         = [each.value.record]
}

##### END PART #####