# Requests a public SSL certificate through AWS Certificate Manager (ACM), then verify with Route53

This module requests a public SSL certificate for your domain, then verify and update Route53 hosted zone for the same domain


For testing, create a `.tfvars` file in the same folder, then refer to it  when running `terraform plan`, like so: `terraform  plan -var-file="test.tfvars"`. *NOTE:* check `variables.tf` for required parameters during runtime. Or copy and rename file `example.tfvars`

For AWS credentials, create a `credentials` file in your `HOME` directory, then pass in the profile name in your `.tfvars` file