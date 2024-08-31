output "cloudfront_distribution_domain_name" {
  description = "Domain name generated from creation of CloudFront distribution"
  value       = aws_cloudfront_distribution.production_distribution.domain_name
}

output "s3_frontend_bucket_name" {
  description = "Name of created S3 bucket for storing front end code"
  value       = aws_s3_bucket.frontend_bucket.id
}

output "cfdistro_response_headers_policy_id" {
  description = "CloudFront distribution's response header's id"
  value       = aws_cloudfront_response_headers_policy.cfdistro_response_headers.id
}

output "cfdistro_oac_id" {
  description = "CloudFront distribution's OAC id"
  value       = aws_cloudfront_origin_access_control.production_oac.id
}

output "cfdistro_id" {
  description = "CloudFront distribution's id"
  value       = aws_cloudfront_distribution.production_distribution.id
}