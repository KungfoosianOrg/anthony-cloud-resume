output "ghactions_aws_role_arn" {
  description = "ARN of AWS role for GitHub Actions to assume"
  value       = module.github-ci-cd.ghactions_oidc_role_arn
}

output "s3_frontend_bucket_name" {
  description = "Name of created S3 bucket for storing front end code"
  value       = module.sam-s3-cloudfront-static-site-hsts.s3_frontend_bucket_name
}

output "s3_frontend_bucket_region" {
  description = "Region of created S3 bucket for storing front end code"
  value       = var.aws_region
}

output "route53_hosted_zone_id" {
  description = "ID of AWS Route53 hosted zone for your domain"
  value       = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary[0].id : var.route53_hosted_zone_id
}

output "cloudfront_distribution_id" {
  description = "AWS CloudFront distribution's id"
  value       = module.sam-s3-cloudfront-static-site-hsts.cfdistro_id
}

output "visitor_counter-api_invoke_url" {
  description = "API endpoint URL to trigger visitor counter API"
  value = "${module.visitor_counter.visitor_counter-api_invoke_url}/${var.visitor_counter-api_route_key}"
}

output "visitor_counter-lambda_arn" {
  value = module.visitor_counter.lambda_arn
}

output "slack_integration-lambda_arn" {
  value = module.slack_integration.lambda_arn
}