output "acm_certificate_arn" {
  description = "ARN of ACM certificate for the custom domain (if custom domain name parameter is defined)"
  value       = aws_acm_certificate.ssl_cert.arn
}