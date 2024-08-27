terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# https://developer.hashicorp.com/terraform/tutorials/modules/modulehttps://developer.hashicorp.com/terraform/tutorials/modules/module