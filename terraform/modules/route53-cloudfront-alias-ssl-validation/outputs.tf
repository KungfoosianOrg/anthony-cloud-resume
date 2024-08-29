output "acm_certificate_arn" {
  description = "ARN of ACM certificate for the custom domain (if custom domain name parameter is defined)"
  value       = aws_acm_certificate.ssl_cert.arn
}

output "route53_hostedzone_id" {
  description = "ID of AWS Route53 hosted zone created for a custom domain"
  value = aws_route53_zone.primary.zone_id
}