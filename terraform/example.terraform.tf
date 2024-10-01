# Copy to your own terraform.tf, un-comment, and edit as neccesary

# terraform {
#     cloud {
#       organization = "test-terraform-org"

#       workspaces {
#         name = "test-terraform-workspace"
#       }
#     }

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# Configure the AWS Provider
# provider "aws" {
#   region  = var.aws_region
#   profile = var.aws_profile
# }

# or OIDC
# provider "aws" {
#   region = var.aws_region
# }