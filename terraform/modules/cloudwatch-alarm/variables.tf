variable "aws_region" {
  description = "Needs to be us-east-1 since AWS creates and validates SSL cert"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name for cloudwatch alarm and SNS topic"
  type        = string
  default     = "mySNSTopic"
}

variable "notification_email" {
  description = "Email to send SNS notifications topic"
  type        = string
  default     = ""
}

variable "measured_metric" {
  description = "Metric to create alarm on"
  type        = string
  default     = ""
}

variable "api_gw_id" {
  description = "ID of API Gateway to create alarm for"
  type        = string
  default     = ""
}

variable "measuring_period" {
  description = "Number representing the alarm measuring period (in seconds)"
  type        = number
  default     = 300
}

variable "statistic_calculation_method" {
  description = "Method used to calculate received data for making alert decisions"
  type        = string
  default     = "Sum"
}

variable "alarm_threshold" {
  description = "Amount that calculated statistics need to exceed before alarm "
  type        = number
  default     = 1.0
}

variable "alarm_description" {
  description = "Description of what this alarm is for"
  type        = string
  default     = ""
}

