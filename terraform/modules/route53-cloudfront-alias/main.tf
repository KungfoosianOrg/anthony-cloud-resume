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
  region = var.aws_region
}


resource "aws_route53_record" "ip4_alias_records" {
  for_each = toset(var.fqdns)

  zone_id = var.route53_hosted_zone_id
  name = each.value
  type = "A"

  alias {
    name = var.cloudfront_distribution_fqdn
    zone_id = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ip6_alias_records" {
  for_each = toset(var.fqdns)

  zone_id = var.route53_hosted_zone_id
  name = each.value
  type = "AAAA"

  alias {
    name = var.cloudfront_distribution_fqdn
    zone_id = var.default_cloudfront_hostedzone
    evaluate_target_health = false
  }
}   

