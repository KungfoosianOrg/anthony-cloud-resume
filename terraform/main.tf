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

# https://developer.hashicorp.com/terraform/tutorials/modules/modulehttps://developer.hashicorp.com/terraform/tutorials/modules/module
module "route53-cloudfront-alias-module" {
  source = "./modules/route53-cloudfront-alias"

  registered_domain_name       = var.registered_domain_name
  subdomains                   = var.subdomains
  route53_hosted_zone_id       = var.route53_hosted_zone_id
  cloudfront_distribution_fqdn = "" # TODO: point to output of SiteStack
}