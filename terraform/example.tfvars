registered_domain_name        = "mydomain.tld"
subdomains                    = ["www", "test", "resume"]
# SAM_stack_name                = "my-sam-stack" # might not need this since we'll be using our role with AdminAccess permissions
# apigw_endpoint_url            = "" # for SAM, leave blank for first time running
github_repo_name_full         = "Owner/Repo"
route53_hosted_zone_id        = "" # zone might need to be created manually to avoid being charged for multiple zone creation (if leave blank) as result of template automation
notification_subscriber_email = "mail@mail.com"
slack_webhook_url             = "slackwebhook.url"

visitor_counter-api_trigger_method = "GET"
visitor_counter-api_route_key = "my-api-route"

aws_region  = "us-east-1" # need to be us-east-1 (default) sinice there will be SSL cert hosting
aws_profile = "1263574337_AWSAccess"