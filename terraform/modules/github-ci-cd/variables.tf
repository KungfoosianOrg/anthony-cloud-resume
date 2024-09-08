variable "github_repo_full_name" {
  description = "Full path of GitHub repository, format: <owner>/<repository name>"
  type = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = ""
}