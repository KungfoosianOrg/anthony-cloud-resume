output "SAM_bucket_name" {
  description = "Name of the created SAM bucket to store sam artifacts in, help w/ automation"
  value       = element(split(".", aws_s3_bucket.sam_artifacts_bucket.bucket_domain_name), 0)
}