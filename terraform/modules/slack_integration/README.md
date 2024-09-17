# Sets up Slack integration using Lambda

For testing, create a `.tfvars` file in the same folder, then refer to it  when running `terraform plan`, like so: `terraform  plan -var-file="test.tfvars"`. *NOTE:* check `variables.tf` for required parameters during runtime

For AWS credentials, create a `credentials` file in your `HOME` directory, then pass in the profile name in your `.tfvars` file