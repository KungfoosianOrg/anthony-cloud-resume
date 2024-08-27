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

# create CNAME record for certificate validation
resource "aws_route53_record" "ssl_cert_validation_records" {
  # this gets all the domain validation options, map it to an object, then loop through them w/ for_each to create each record
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