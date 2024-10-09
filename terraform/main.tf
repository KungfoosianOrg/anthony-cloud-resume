# This template creates the static website hosting, custom domain validation, SSL
# TODO:
#   DNSSEC for hosted zone



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

  aws_region  = var.aws_region
}

module "sam-s3-cloudfront-static-site-hsts" {
  source = "./modules/sam-s3-cloudfront-static-site-hsts"

  registered_domain_name = var.registered_domain_name
  subdomains             = var.subdomains
  route53_hosted_zone_id = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary[0].id : var.route53_hosted_zone_id
  ghactions_aws_role_name = module.github-ci-cd.ghactions_oidc_role_name
  acm_certificate_arn    = module.route53-cloudfront-alias-w-ssl-validation.acm_certificate_arn

  aws_cicd_role-name = module.github-ci-cd.ghactions_oidc_role_name

  aws_region  = var.aws_region
}

module "github-ci-cd" {
  source = "./modules/github-ci-cd"

  github_repo_full_name = var.github_repo_name_full

  aws_region  = var.aws_region
}

module "visitor_counter" {
  source = "./modules/visitor_counter"

  # triggers API for HTTP POST requests to /visitor-counter
  api_trigger_method = "POST"
  api_route_key = "visitor-counter"

  aws_region  = var.aws_region
  source_relative_path = var.lambda_placeholder-source_relative_path

  aws_cicd_role-name = module.github-ci-cd.ghactions_oidc_role_name
}

# devops-alarms
module "alarm-api_response_4xx" {
  source = "./modules/cloudwatch-alarm"
  
  notification_email = var.notification_email

  name              = "4xxApiResponse"
  measured_metric   = "4xx"
  api_gw_id         = module.visitor_counter.apigw_id
  alarm_description = "alarms when api gateway HTTP response is 4xx"

  aws_region  = var.aws_region
}

module "alarm-api_response_5xx" {
  source = "./modules/cloudwatch-alarm"

  notification_email = var.notification_email

  name              = "5xxApiResponse"
  measured_metric   = "5xx"
  api_gw_id         = module.visitor_counter.apigw_id
  alarm_description = "alarms when api gateway HTTP response is 4xx"

  aws_region  = var.aws_region
}

module "alarm-api_response_latency" {
  source = "./modules/cloudwatch-alarm"

  notification_email = var.notification_email

  name                         = "ApiResponseLatency"
  measured_metric              = "Latency"
  api_gw_id                    = module.visitor_counter.apigw_id
  alarm_description            = "alarms when api gateway HTTP response takes more than 2 seconds"
  statistic_calculation_method = "Maximum"
  alarm_threshold              = 2000 // in ms

  aws_region  = var.aws_region
}

module "alarm-api_call_exceed_expectation" {
  source = "./modules/cloudwatch-alarm"

  notification_email = var.notification_email

  name                         = "ApiCallExceedExpectation"
  measured_metric              = "Count"
  api_gw_id                    = module.visitor_counter.apigw_id
  statistic_calculation_method = "SampleCount"
  alarm_description            = "alarms when api calls exceed 100 within 1 minute"
  alarm_threshold              = 100
  measuring_period             = 60 // seconds

  aws_region  = var.aws_region
}
# END devops-alarms


##### SECTION - Slack integration #####
module "slack_integration" {
  source = "./modules/slack_integration"

  source_relative_path = var.lambda_placeholder-source_relative_path
  aws_region  = var.aws_region

  aws_cicd_role-name = module.github-ci-cd.ghactions_oidc_role_name

  slack_webhook_url = var.slack_webhook_url
}

# gathers the ARN's of the SNS topics to register the lambda that will run Slack integration
locals {
cw_alarm-modules = {
  alarm-api_call_exceed_expectation = module.alarm-api_call_exceed_expectation
  alarm-api_response_latency = module.alarm-api_response_latency
  alarm-api_response_5xx = module.alarm-api_response_5xx
  alarm-api_response_4xx = module.alarm-api_response_4xx
}
  
  sns_topic_arn_list = [
    for module_name in local.cw_alarm-modules:
      module_name.sns_topic_arn
  ]
}


resource "aws_sns_topic_subscription" "lambda_subscription" {
  count = length(local.sns_topic_arn_list)

  endpoint  = module.slack_integration.lambda_arn
  protocol  = "lambda"
  topic_arn = local.sns_topic_arn_list[count.index]
}
##### END SECTION #####
