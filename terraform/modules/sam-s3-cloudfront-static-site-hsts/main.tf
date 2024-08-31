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

variable "csp_parts" {
  type = list(string)

  default = [ 
    "default-src 'self' https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
    "base-uri 'self' https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
    "frame-src https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
    "frame-ancestors 'self' https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
    "form-action 'none'",
    "style-src https://${var.registered_domain_name} https://*.${var.registered_domain_name} https://cdn.jsdelivr.net",
    "script-src https://${var.registered_domain_name} https://*.${var.registered_domain_name} https://cdn.jsdelivr.net",
    "connect-src ${ApiEndpointUrlParam}",
    "img-src https://${var.registered_domain_name} https://*.${var.registered_domain_name} data: w3.org/svg/2000"
  ]
}

resource "aws_cloudfront_response_headers_policy" "cfdistro_response_headers" {
  name = "${aws_s3_bucket.frontend_bucket.id}_response-header-policy"

  security_headers_config {
    content_security_policy {
      override = true

      content_security_policy = join(";", var.csp_parts)
    }

    content_type_options {
      override = true
    }

    strict_transport_security {
      override = true
      include_subdomains = true
      preload = true
      access_control_max_age_sec = 31536000
    }
  }
}

resource "aws_s3_bucket" "frontend_bucket" {
  
}


