registered_domain_name        = "mydomain.tld"
github_repo_name_full         = "Owner/Repo"
route53_hosted_zone_id        = "" # zone might need to be created manually to avoid being charged for multiple zone creation (if leave blank) as result of template automation
notification_subscriber_email = "mail@mail.com"
slack_webhook_url             = "slackwebhook.url"

visitor_counter-api_trigger_method = "GET"
visitor_counter-api_route_key      = "my-api-route"