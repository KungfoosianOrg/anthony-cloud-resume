## Sets up Terraform as an OIDC provider with AWS, returns the role's ARN for CI/CD automation with GitHub Actions (GHA). This will need to be (re)run manually, or automated with manual approval, if there any updates to the permissions listed, or if it's the first time creating the application

**NOTE** For CI/CD purposes with GitHub Actions and Terraform, this module needs to be run first before the root module is run. For this, you need to generate a token with Terraform and store it locally (e.g. in the `~/.terraformrc` file). The output from this module will be the ARN to the AWS IAM role created for Terraform to create the rest of the project's infrastructure.

Copy the content of and rename `example.terraform.tf` to what ever you like (e.g. to a file called `terraform.tf`), uncomment the code, and change the values accordingly. This is so I can separate the template file and have my own files for different stages of development

For testing, create a `.tfvars` file in the same folder, then refer to it  when running `terraform plan`, like so: `terraform  plan -var-file="test.tfvars"`. **NOTE:** check `variables.tf` for required parameters during runtime

For AWS credentials, create a `credentials` file in your `HOME` directory, then pass in the profile name in your `.tfvars` file