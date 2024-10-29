# SAM supported - Sets up S3 bucket with CloudFront distribution for serving static page from S3, custom CloudFront SSL certificate, HSTS enabled

This module creates a static site hosted in AWS S3, served by CloudFront, with HSTS enabled. AWS SAM supported

For testing, create a `.tfvars` file in the same folder, then refer to it  when running `terraform plan`, like so: `terraform  plan -var-file="test.tfvars"`. *NOTE:* check `variables.tf` for required parameters during runtime

For AWS credentials, create a `credentials` file in your `HOME` directory, then pass in the profile name in your `.tfvars` file