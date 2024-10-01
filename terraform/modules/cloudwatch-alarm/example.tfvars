aws_region  = "aws-region-1"
# aws_profile = "12345_Admin"
aws_role_arn = "aws:arn:1234:abcd"

name                          = "My alarm name"
notification_subscriber_email = "email@mail.com"
measured_metric               = "Count"
api_gw_id                     = "123456ABCDE"
measuring_period              = 60
statistic_calculation_method  = "SampleCount"
alarm_threshold               = 100
alarm_description             = "my alarm description"
lambda_subscriber_arn = "arn:aws:lambda:blablabla"