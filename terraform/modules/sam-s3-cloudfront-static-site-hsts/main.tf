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


