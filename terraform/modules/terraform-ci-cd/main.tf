


# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "oidcprovider_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current}:oidc-provider/app.terraform.io"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:${var.my_terraform_org}:project:${var.terraform_project_name}:workspace:${var.terraform_workspace}:run_phase:${var.terraform_workspace-run_phase}"]
    }

  }
}


resource "aws_iam_role" "terraform_oidc_aws_provider" {
  description = "for GitHub Actions to assume role and run custom event"

  assume_role_policy = data.aws_iam_policy_document.oidcprovider_assume_role.json
}

# TODO: copy permissions used in TerraformAdminAccess role for permission policy