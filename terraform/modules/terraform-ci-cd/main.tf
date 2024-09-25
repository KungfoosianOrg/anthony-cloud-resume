data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "oidcprovider_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/app.terraform.io"]
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
data "aws_iam_policy_document" "terraform_oidc_permissions" {
  version = "2012-10-17"

  statement {
    sid = "Statement1"
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ListQueryLoggingConfigs",
      "route53:GetHostedZoneCount",
      "route53:ListHostedZonesByName",
      "route53:GetHealthCheckCount",
      "route53:ListTrafficPolicies"
    ]

    resources = ["*"] # TODO: narrow down resource
  }
		{
			"Sid": "Statement2",
			"Effect": "Allow",
			"Action": [
				"dynamodb:DescribeTable",
				"dynamodb:DeleteTable",
				"dynamodb:DescribeTimeToLive",
				"dynamodb:DescribeContinuousBackups",
				"dynamodb:CreateTable"
			],
			"Resource": []
		}
  }
}


resource "aws_iam_policy" "terraform_oidc" {
  policy = data.aws_iam_policy_document.terraform_oidc_permissions.json
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.terraform_oidc_aws_provider.name

  policy_arn = aws_iam_policy.terraform_oidc.arn
}