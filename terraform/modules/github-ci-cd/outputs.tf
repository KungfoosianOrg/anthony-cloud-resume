output "ghactions_oidc_role_name" {
  description = "Name of AWS role for GitHub Actions to assume, for GitHub Actions"
  value       = aws_iam_role.ghactions_oidc_aws_provider.name
}

output "ghactions_oidc_role_arn" {
  description = "ARN of AWS role for GitHub Actions to assume, for GitHub Actions"
  value       = aws_iam_role.ghactions_oidc_aws_provider.arn
}