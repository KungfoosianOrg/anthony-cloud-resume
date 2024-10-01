variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = ""
}

variable "my_terraform_org" {
  description = "Name of Terraform organization"
  type        = string
  default     = ""
}

variable "terraform_workspace" {
  description = "Name of Terraform workspace to run this module in"
  type        = string
  default     = "*"
}

variable "terraform_project_name" {
  type    = string
  default = "*"
}

variable "terraform_workspace-run_phase" {
  type    = string
  default = "*"
}