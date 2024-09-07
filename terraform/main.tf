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


resource "aws_route53_zone" "primary" {
  name = var.registered_domain_name
}


module "route53-cloudfront-alias-w-ssl-validation" {
  source = "./modules/route53-cloudfront-alias-ssl-validation"

  registered_domain_name       = var.registered_domain_name
  subdomains                   = var.subdomains
  route53_hosted_zone_id       = aws_route53_zone.primary.id
  cloudfront_distribution_fqdn = module.sam-s3-cloudfront-static-site-hsts.cloudfront_distribution_domain_name

  aws_profile = var.aws_profile
  aws_region = var.aws_region
}

module "sam-s3-cloudfront-static-site-hsts" {
  source = "./modules/sam-s3-cloudfront-static-site-hsts"

  registered_domain_name = var.registered_domain_name
  subdomains = var.subdomains
  route53_hosted_zone_id = aws_route53_zone.primary.id
  ghactions_aws_role_arn = "" # TODO: point to output of GitHubCICDStack
  acm_certificate_arn = module.route53-cloudfront-alias-w-ssl-validation.acm_certificate_arn

  aws_region = var.aws_region
  aws_profile = var.aws_profile
}

module "sam-visitor-counter-permission" {
  source = "./modules/sam-visitor-counter-permission"

  ghactions_aws_role_arn = ""
  cfdistro_response_headers_policy_id = module.sam-s3-cloudfront-static-site-hsts.cfdistro_response_headers_policy_id
  cfdistro_oac_id = module.sam-s3-cloudfront-static-site-hsts.cfdistro_oac_id
  cfdistro_id = module.sam-s3-cloudfront-static-site-hsts.cfdistro_id

  aws_region = var.aws_region
  aws_profile = var.aws_profile
}