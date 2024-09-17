output "slack_integration-lambda_arn" {
  description = "ARN of Lambda function for Slack integration"
  value       = aws_lambda_function.slack_integration.arn
}