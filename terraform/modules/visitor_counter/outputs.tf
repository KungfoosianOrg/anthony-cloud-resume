output "apigw_id" {
  description = "ID of created API gateway"
  value       = aws_apigatewayv2_api.visitor_counter-api.id
}