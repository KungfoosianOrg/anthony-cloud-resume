variable "aws_region" {
  description = "Needs to be us-east-1 since AWS creates and validates SSL cert"
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}