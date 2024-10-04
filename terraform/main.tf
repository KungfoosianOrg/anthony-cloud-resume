# This template creates the static website hosting, custom domain validation, SSL
# TODO:
#   DNSSEC for hosted zone
#   https://www.hashicorp.com/blog/access-aws-from-hcp-terraform-with-oidc-federation


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

  # aws_profile = var.aws_profile
  aws_region  = var.aws_region
  # aws_role_arn = var.aws_role_arn
}

module "sam-s3-cloudfront-static-site-hsts" {
  source = "./modules/sam-s3-cloudfront-static-site-hsts"

  registered_domain_name = var.registered_domain_name
  subdomains             = var.subdomains
  route53_hosted_zone_id = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary[0].id : var.route53_hosted_zone_id
  ghactions_aws_role_name = module.github-ci-cd.ghactions_oidc_role_name
  acm_certificate_arn    = module.route53-cloudfront-alias-w-ssl-validation.acm_certificate_arn

  aws_region  = var.aws_region
  # aws_profile = var.aws_profile
}

# might not need this since we'll be using our role with AdminAccess permissions
# module "sam-visitor-counter-permission" {
#   source = "./modules/sam-visitor-counter-permission"

#   ghactions_aws_role_arn              = module.github-ci-cd.ghactions_oidc_role_arn
#   cfdistro_response_headers_policy_id = module.sam-s3-cloudfront-static-site-hsts.cfdistro_response_headers_policy_id
#   cfdistro_oac_id                     = module.sam-s3-cloudfront-static-site-hsts.cfdistro_oac_id
#   cfdistro_id                         = module.sam-s3-cloudfront-static-site-hsts.cfdistro_id
#   SAM_stack_name                      = var.SAM_stack_name

#   aws_region  = var.aws_region
#   aws_profile = var.aws_profile
# }

module "github-ci-cd" {
  source = "./modules/github-ci-cd"

  github_repo_full_name = var.github_repo_name_full

  aws_region  = var.aws_region
  # aws_profile = var.aws_profile
  # aws_role_arn = var.aws_role_arn
}

module "visitor_counter" {
  source = "./modules/visitor_counter"

  # triggers API for HTTP POST requests to /visitor-counter
  api_trigger_method = "POST"
  api_route_key = "visitor-counter"

  aws_region  = var.aws_region
  source_relative_path = var.lambda_placeholder-source_relative_path

  # aws_profile = var.aws_profile
  # aws_role_arn = var.aws_role_arn
}

# devops-alarms
module "alarm-api_response_4xx" {
  source = "./modules/cloudwatch-alarm"
  
  notification_email = var.notification_email
  # need_lambda_integration = true
  # lambda_subscriber_arn         = module.slack_integration.slack_integration-lambda_arn

  name              = "4xxApiResponse"
  measured_metric   = "4xx"
  api_gw_id         = module.visitor_counter.apigw_id
  alarm_description = "alarms when api gateway HTTP response is 4xx"

  aws_region  = var.aws_region
  # aws_profile = var.aws_profile
  # aws_role_arn = var.aws_role_arn
}

module "alarm-api_response_5xx" {
  source = "./modules/cloudwatch-alarm"

  notification_email = var.notification_email
  # need_lambda_integration = true
  # lambda_subscriber_arn         = module.slack_integration.slack_integration-lambda_arn

  name              = "5xxApiResponse"
  measured_metric   = "5xx"
  api_gw_id         = module.visitor_counter.apigw_id
  alarm_description = "alarms when api gateway HTTP response is 4xx"

  aws_region  = var.aws_region
  # aws_profile = var.aws_profile
  # aws_role_arn = var.aws_role_arn
}

module "alarm-api_response_latency" {
  source = "./modules/cloudwatch-alarm"

  notification_email = var.notification_email
  # need_lambda_integration = true
  # lambda_subscriber_arn         = module.slack_integration.slack_integration-lambda_arn

  name                         = "ApiResponseLatency"
  measured_metric              = "Latency"
  api_gw_id                    = module.visitor_counter.apigw_id
  alarm_description            = "alarms when api gateway HTTP response takes more than 2 seconds"
  statistic_calculation_method = "Maximum"
  alarm_threshold              = 2000 // in ms

  aws_region  = var.aws_region
  # aws_profile = var.aws_profile
  # aws_role_arn = var.aws_role_arn
}

module "alarm-api_call_exceed_expectation" {
  source = "./modules/cloudwatch-alarm"

  notification_email = var.notification_email
  # need_lambda_integration = true
  # lambda_subscriber_arn         = module.slack_integration.slack_integration-lambda_arn

  name                         = "ApiCallExceedExpectation"
  measured_metric              = "Count"
  api_gw_id                    = module.visitor_counter.apigw_id
  statistic_calculation_method = "SampleCount"
  alarm_description            = "alarms when api calls exceed 100 within 1 minute"
  alarm_threshold              = 100
  measuring_period             = 60 // seconds

  aws_region  = var.aws_region
  # aws_profile = var.aws_profile
  # aws_role_arn = var.aws_role_arn
}
# END devops-alarms


##### SECTION - Slack integration #####
module "slack_integration" {
  source = "./modules/slack_integration"

  source_relative_path = var.lambda_placeholder-source_relative_path
  aws_region  = var.aws_region

  slack_webhook_url = var.slack_webhook_url
  # aws_profile = var.aws_profile
  # aws_role_arn = var.aws_role_arn
}

# gathers the ARN's of the SNS topics to register the lambda that will run Slack integration
variable "sns_topic_arns" {
  description = "Collection of SNS topics' ARN's to register the lambda that will run Slack integration"
  type = list(string)
  
  default = [
    module.alarm-api_call_exceed_expectation.sns_topic_arn,
    module.alarm-api_response_latency.sns_topic_arn,
    module.alarm-api_response_5xx.sns_topic_arn,
    module.alarm-api_response_4xx.sns_topic_arn
  ]
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  count = length(var.sns_topic_arns)

  endpoint  = module.slack_integration.slack_integration-lambda_arn
  protocol  = "lambda"
  topic_arn = var.sns_topic_arns[count.index]
}
##### END SECTION #####
