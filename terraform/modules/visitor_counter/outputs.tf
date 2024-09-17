output "apigw_id" {
  description = "ID of created API gateway"
  value       = aws_apigatewayv2_api.visitor_counter-api.id
}

output "visitor_counter-apigw_invoke_url" {
  description = "Invoke URL for visitor counter API"
  value = aws_apigatewayv2_api.visitor_counter-api.api_endpoint
}