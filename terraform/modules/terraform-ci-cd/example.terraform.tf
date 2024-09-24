terraform {
    cloud {
      organization = "test-terraform-org"

      workspaces {
        name = "test-terraform-workspace"
      }
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}