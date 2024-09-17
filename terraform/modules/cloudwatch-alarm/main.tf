# This templates create a CloudWatch alarm

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

resource "aws_sns_topic" "sns_topic" {
  name = var.name
}

resource "aws_sns_topic_subscription" "email_subscription" {
  count = var.notification_subscriber_email == "" ? 0 : 1

  endpoint  = var.notification_subscriber_email
  protocol  = "email"
  topic_arn = aws_sns_topic.sns_topic.arn
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  count = var.lambda_subscriber_arn == "" ? 0 : 1

  endpoint  = var.lambda_subscriber_arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.sns_topic.arn
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm" {
  alarm_name          = var.name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = var.measured_metric
  namespace           = "AWS/ApiGateway"
  period              = var.measuring_period
  statistic           = var.statistic_calculation_method
  threshold           = var.alarm_threshold
  alarm_actions       = [aws_sns_topic.sns_topic.arn]
  alarm_description   = var.alarm_description
}