# TODO: Group permissions by module used by root template

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

  # statement {
  #   sid = "Statement1"
  #   effect = "Allow"
  #   actions = [
  #     "route53:GetChange",
  #     "route53:ChangeResourceRecordSets",
  #     "route53:GetHostedZone",
  #     "route53:ListResourceRecordSets",
  #     "route53:ListQueryLoggingConfigs",
  #     "route53:GetHostedZoneCount",
  #     "route53:ListHostedZonesByName",
  #     "route53:GetHealthCheckCount",
  #     "route53:GetTrafficPolicyInstanceCount",
  #     "route53:ListTrafficPolicies"
  #   ]

  #   resources = ["*"] # TODO: narrow down resource
  # }
	
  statement	{
    sid = "Statement2"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:CreateTable"
    ]
    resources = []
  }

  # statement {
  #   sid = "statement3"
  #   effect = "Allow"
  #   actions = [
  #     "s3:DeleteBucket",
  #     "s3:GetBucketPolicy",
  #     "s3:DeleteBucketPolicy",
  #     "s3:PutBucketPublicAccessBlock",
  #     "s3:GetBucketPublicAccessBlock",
  #     "s3:GetBucketVersioning",
  #     "s3:PutBucketVersioning",
  #     "s3:GetBucketLogging",
  #     "s3:GetBucketObjectLockConfiguration",
  #     "s3:GetEncryptionConfiguration",
  #     "s3:GetLifecycleConfiguration",
  #     "s3:GetReplicationConfiguration",
  #     "s3:GetAccelerateConfiguration",
  #     "s3:GetBucketAcl",
  #     "s3:GetBucketCORS",
  #     "s3:GetBucketRequestPayment",
  #     "s3:GetBucketWebsite",
  #     "s3:PutBucketPolicy",
  #     "s3:CreateBucket"
  #   ]
  # }
  
  statement {
    sid = "Statement4"
    effect = "Allow"
    actions = [
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "acm:RequestCertificate"
    ]
  }

   statement {
     sid = "Statement5"
     effect = "Allow"
     actions = [
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:CreateResponseHeadersPolicy",
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:DeleteResponseHeadersPolicy",
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:UpdateDistribution",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm"
    ]
  }

  statement {
    sid = "CreateRolesForGitHubActionsAndTerraform"
    effect = "Allow"
    actions = [
    "iam:CreateOpenIDConnectProvider",
    "iam:CreateServiceLinkedRole",
    "iam:DeleteOpenIDConnectProvider",
    "iam:DeletePolicy",
    "iam:CreateRole",
    "iam:DeleteRole",
    "iam:CreatePolicy",
    "iam:DetachRolePolicy",
    "iam:GetPolicy",
    "iam:GetPolicyVersion",
    "iam:GetOpenIDConnectProvider",
    "iam:DeleteRolePolicy",
    "iam:GetRole",
    "iam:ListAttachedRolePolicies",
    "iam:GetRolePolicy",
    "iam:ListRolePolicies",
    "iam:ListInstanceProfilesForRole",
    "iam:AttachRolePolicy",
    "iam:PutRolePolicy",
    "iam:ListPolicyVersions"
    ]
  }
}


resource "aws_iam_policy" "terraform_oidc" {
  policy = data.aws_iam_policy_document.terraform_oidc_permissions.json
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.terraform_oidc_aws_provider.name

  policy_arn = aws_iam_policy.terraform_oidc.arn
}