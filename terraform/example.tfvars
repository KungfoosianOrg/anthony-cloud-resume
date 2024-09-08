registered_domain_name = "mydomain.tld"
subdomains             = ["www", "test", "resume"]
SAM_stack_name         = "my-sam-stack"
apigw_endpoint_url     = "" # for SAM
github_repo_name_full  = "Owner/Repo"
route53_hosted_zone_id = "" # zone might need to be created manually to avoid being charged for multiple zone creation (if leave blank) as result of template automation

aws_region  = "us-west-1"
aws_profile = "590183800837_AdministratorAccess"