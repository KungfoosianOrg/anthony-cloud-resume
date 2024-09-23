# Sets up Terraform as an OIDC provider with AWS, returns the role's ARN for CI/CD automation with GitHub Actions (GHA). This might need to be (re)run manually if there any updates to the permissions listed, or if it's the first time creating the application

For testing, create a `.tfvars` file in the same folder, then refer to it  when running `terraform plan`, like so: `terraform  plan -var-file="test.tfvars"`. *NOTE:* check `variables.tf` for required parameters during runtime

For AWS credentials, create a `credentials` file in your `HOME` directory, then pass in the profile name in your `.tfvars` file