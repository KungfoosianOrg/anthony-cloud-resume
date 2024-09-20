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

# output "SAM_stack_name" {
#   description = "Name of SAM stack"
#   value       = var.SAM_stack_name
# }

# output "SAM_bucket_name" {
#   description = "Name of the created SAM bucket to store sam artifacts in, help w/ automation"
#   value       = module.sam-visitor-counter-permission.SAM_bucket_name
# }

output "route53_hosted_zone_id" {
  description = "ID of AWS Route53 hosted zone for your domain"
  value       = var.route53_hosted_zone_id == "" ? aws_route53_zone.primary[0].id : var.route53_hosted_zone_id
}

output "cloudfront_distribution_id" {
  description = "AWS CloudFront distribution's id"
  value       = module.sam-s3-cloudfront-static-site-hsts.cfdistro_id
}

output "cloudformation_root_stack_id" {
  description = "ID of the AWS CloudFormation root stack"
  value       = "TODO !Ref AWS::StackId"
}

output "visitor_counter-api_invoke_url" {
  description = "ID of deployed stage for visitor counter API"
  value = module.visitor_counter.visitor_counter-api_invoke_url
}