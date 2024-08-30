output "ghactions_aws_role_arn" {
  description = "ARN of AWS role for GitHub Actions to assume"
  value       = "TODO GitHubCICDStack, Outputs.GHActionAWSRoleARN"
}

output "s3_frontend_bucket_name" {
  description = "Name of created S3 bucket for storing front end code"
  value       = "TODO SiteStack, Outputs.ProdBucketNameOutput"
}

output "s3_frontend_bucket_region" {
  description = "Region of created S3 bucket for storing front end code"
  value       = var.aws_region
}

output "SAM_stack_name" {
  description = "Name of SAM stack"
  value       = var.SAM_stack_name
}

output "route53_hosted_zone_id" {
  description = "ID of AWS Route53 hosted zone for your domain"
  value       = var.route53_hosted_zone_id
}

output "cloudfront_distribution_id" {
  description = "AWS CloudFront distribution's id"
  value       = "TODO SiteStack Outputs.CfDistributionIdOutput"
}

output "cloudformation_root_stack_id" {
  description = "ID of the AWS CloudFormation root stack"
  value       = "TODO !Ref AWS::StackId"
}