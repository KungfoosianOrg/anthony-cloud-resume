output "slack_integration-lambda_arn" {
  description = "ARN of Lambda function for Slack integration"
  value       = module.slack_integration-lambda.lambda_function_arn
}