# This template creates the static website hosting, custom domain validation, SSL

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

# if no zone id is passed in, creates the zone and keeps it in event of deletion
resource "aws_route53_zone" "primary" {
  count = var.route53_hosted_zone_id == "" ? 1 : 0

  name = var.registered_domain_name

  lifecycle {
    prevent_destroy = true
  }
}


module "route53-cloudfront-alias-w-ssl-validation" {
  source = "./modules/route53-cloudfront-alias-ssl-validation"

  registered_domain_name       = var.registered_domain_name
  subdomains                   = var.subdomains
  route53_hosted_zone_id       = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary[0].id : var.route53_hosted_zone_id
  cloudfront_distribution_fqdn = module.sam-s3-cloudfront-static-site-hsts.cloudfront_distribution_domain_name

  aws_profile = var.aws_profile
  aws_region  = var.aws_region
}

module "sam-s3-cloudfront-static-site-hsts" {
  source = "./modules/sam-s3-cloudfront-static-site-hsts"

  registered_domain_name = var.registered_domain_name
  subdomains             = var.subdomains
  route53_hosted_zone_id = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary[0].id : var.route53_hosted_zone_id
  ghactions_aws_role_arn = module.github-ci-cd-module.ghactions_oidc_role_arn
  acm_certificate_arn    = module.route53-cloudfront-alias-w-ssl-validation.acm_certificate_arn

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "sam-visitor-counter-permission" {
  source = "./modules/sam-visitor-counter-permission"

  ghactions_aws_role_arn              = module.github-ci-cd-module.ghactions_oidc_role_arn
  cfdistro_response_headers_policy_id = module.sam-s3-cloudfront-static-site-hsts.cfdistro_response_headers_policy_id
  cfdistro_oac_id                     = module.sam-s3-cloudfront-static-site-hsts.cfdistro_oac_id
  cfdistro_id                         = module.sam-s3-cloudfront-static-site-hsts.cfdistro_id
  SAM_stack_name                      = var.SAM_stack_name

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "github-ci-cd-module" {
  source = "./modules/github-ci-cd"

  github_repo_full_name = var.github_repo_name_full

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "visitor_counter-module" {
  source = "./modules/visitor_counter"

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

# devops-alarms
module "alarm-api_response_4xx" {
  source = "./modules/cloudwatch-alarm"

  name = "4xxApiResponse"
  notification_subscriber_email = var.notification_subscriber_email
  measured_metric = "4xx"
  api_gw_id = module.visitor_counter-module.apigw_id
  alarm_description = "alarms when api gateway HTTP response is 4xx"

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "alarm-api_response_5xx" {
  source = "./modules/cloudwatch-alarm"

  name = "5xxApiResponse"
  notification_subscriber_email = var.notification_subscriber_email
  measured_metric = "5xx"
  api_gw_id = module.visitor_counter-module.apigw_id
  alarm_description = "alarms when api gateway HTTP response is 4xx"

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "alarm-api_response_latency" {
  source = "./modules/cloudwatch-alarm"

  name = "ApiResponseLatency"
  notification_subscriber_email = var.notification_subscriber_email
  measured_metric = "Latency"
  api_gw_id = module.visitor_counter-module.apigw_id
  alarm_description = "alarms when api gateway HTTP response takes more than 2 seconds"
  statistic_calculation_method = "Maximum"
  alarm_threshold = 2000 // in ms

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "alarm-api_call_exceed_expectation" {
  source = "./modules/cloudwatch-alarm"

  name = "ApiCallExceedExpectation"
  notification_subscriber_email = var.notification_subscriber_email
  measured_metric = "Count"
  api_gw_id = module.visitor_counter-module.apigw_id
  statistic_calculation_method = "SampleCount"
  alarm_description = "alarms when api calls exceed 100 within 1 minute"
  alarm_threshold = 100
  measuring_period = 60 // in second

  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}
# END devops-alarms

module "slack_integration" {}