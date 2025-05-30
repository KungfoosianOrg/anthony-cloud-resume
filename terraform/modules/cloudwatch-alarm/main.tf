# This templates create a CloudWatch alarm

resource "aws_sns_topic" "sns_topic" {
  name = var.name
}

resource "aws_sns_topic_subscription" "email_subscription" {
  count = var.notification_email == "" ? 0 : 1

  endpoint  = var.notification_email
  protocol  = "email"
  topic_arn = aws_sns_topic.sns_topic.arn
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm" {
  alarm_name          = var.name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = var.measured_metric
  period              = var.measuring_period
  statistic           = var.statistic_calculation_method
  threshold           = var.alarm_threshold
  alarm_actions       = [aws_sns_topic.sns_topic.arn]
  alarm_description   = var.alarm_description

  namespace = "AWS/ApiGateway"
  dimensions = {
    ApiId = var.api_gw_id
  }
}