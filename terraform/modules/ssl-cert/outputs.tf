output "acm_certificate_arn" {
  description = "ARN of ACM certificate for the custom domain (if custom domain name parameter is defined)"
  value = # TODO: refer to ssl cert resource output
}