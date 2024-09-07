# This module sets up AWS IAM permission policy for the visitor counter module
# , and attach it to a pre-created role for GitHub Actions


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
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ghactions_sam" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    sid = "S3_SAMBucketAccess"
    actions = [ "s3:*" ]
    resources = [ 
      # TODO: Get ARN of S3 bucket created by SAM to tighten security, or arn:aws:s3:::*samclisourcebucket*
      # TODO: Get ARN of S3 bucket storing templates used (not sure if necessary with Terraform)
     ]
  }

  statement {
    effect = "Allow"
    sid = "CloudFormation_ChangeSetPermissions"
    actions = [ 
      "cloudformation:CreateChangeSet",
      "cloudformation:ExecuteChangeSet"
    ]
    resources = [ 
      "arn:aws:cloudformation:us-east-1:aws:transform/Serverless-2016-10-31",
      "arn:aws:cloudformation:us-east-1:aws:transform/LanguageExtensions",
      "arn:aws:cloudformation:${var.aws_region}:${data.aws_caller_identity.current.account_id}:changeSet/samcli-deploy*"
     ]
  }

  statement {
    effect = "Allow"
    sid = "CloudFormationPermissions"

    actions = [ 
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStacks",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:GetTemplateSummary",
      "cloudformation:ListStackResources",
      "cloudformation:UpdateStack"
    ]

    resources = [ 
      "arn:aws:cloudformation:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stack/*/*"
    ]
  }

  # Continue at SAMLogGroupPermission in sam-visitor-counter-permission
  statement {
    effect = "Allow"
    sid = "SAMLogGroupPermission"
    
    actions = [ 
      "logs:DeleteLogGroup",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:CreateLogDelivery",
      "logs:PutRetentionPolicy",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    resources = [ 
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }

  statement {
    effect = "Allow"
    sid = "SAMCreateLogDelivery"

    actions = [ "logs:CreateLogDelivery" ]

    resources = [ "*" ]
  }

  statement {
    effect = "Allow"
    sid = "SAMDynamoDBPermission"

    actions = [ 
      "dynamodb:DescribeTable",
      "dynamodb:CreateTable",
      "dynamodb:ListTagsOfResource",
      "dynamodb:GetResourcePolicy",
      "dynamodb:DescribeKinesisStreamingDestination",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeContributorInsights",
      "dynamodb:DescribeTimeToLive"
    ]

    resources = [ "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/*" ]
  }
}

resource "aws_s3_bucket" "sam_artifacts_bucket" {}

resource "aws_iam_role_policy" "ghactions_sam_permission_policy" {
  role = var.ghactions_aws_role_arn

  policy = data.aws_iam_policy_document.ghactions_sam.json

  name = "GHActions-SAM-Policy"
}