registered_domain_name       = "my.domain"
subdomains                   = ["www", "test", "resume"]
route53_hosted_zone_id       = "TESTZONE" # leave empty string to create a zone
cloudfront_distribution_fqdn = "something.diistribution.fqdn"
aws_region                   = "us-east-1"
aws_profile                  = "284990350266_TerraformAccess"
is_prod_build                = false # sets up test mode, builds own route53 zone