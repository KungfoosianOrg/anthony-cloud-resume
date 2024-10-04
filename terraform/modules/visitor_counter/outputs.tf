output "apigw_id" {
  description = "ID of created API gateway"
  value       = aws_apigatewayv2_api.visitor_counter-api.id
}

output "visitor_counter-api_invoke_url" {
  description = "ID of deployed stage for visitor counter API"
  value = aws_apigatewayv2_api.visitor_counter-api.api_endpoint
}

output "lambda_arn" {
  value = module.visitor_counter-lambda.lambda_function_arn
}