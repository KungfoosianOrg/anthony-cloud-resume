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

  statement {
    sid    = "Statement1"
    effect = "Allow"
    actions = [
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets"
    ]

    resources = ["*"] # TODO: narrow down resource
  }

  statement {
    sid    = "Statement2"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:CreateTable"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "statement3"
    effect = "Allow"
    actions = [
      "s3:DeleteBucket",
      "s3:GetBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketLogging",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketWebsite",
      "s3:PutBucketPolicy",
      "s3:CreateBucket"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Statement4"
    effect = "Allow"
    actions = [
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "acm:RequestCertificate"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Statement5"
    effect = "Allow"
    actions = [
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:DeleteResponseHeadersPolicy",
      "cloudfront:DeleteDistribution",
      "cloudfront:UpdateDistribution",
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:CreateResponseHeadersPolicy",
      "cloudfront:CreateOriginAccessControl"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Statement6"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:ListAliases",
      "kms:CreateGrant",
      "kms:Encrypt"
    ]

    resources = ["*"]
  }

  statement {
    sid     = "Statement7"
    effect  = "Allow"
    actions = ["sts:GetCallerIdentity"]

    resources = ["*"]
  }

  statement {
    sid    = "Statement8"
    effect = "Allow"
    actions = [
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroup",
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Statement9"
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Statement10"
    effect = "Allow"
    actions = [
      "ssm:DeleteParameter",
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Statement11"
    effect = "Allow"
    actions = [
      "sns:DeleteTopic",
      "sns:GetSubscriptionAttributes",
      "sns:Unsubscribe"
    ]

    resources = [
      "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid    = "Statement12"
    effect = "Allow"
    actions = [
      "lambda:ListTags",
      "lambda:DeleteFunction",
      "lambda:GetPolicy",
      "lambda:RemovePermission",
      "lambda:GetFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:ListVersionsByFunction",
      "lambda:AddPermission",
      "lambda:CreateFunction"
    ]

    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:*"
    ]
  }

  # Might need to update to reflect permission to update stage/deployment/etc...
  statement {
    sid    = "Statement13"
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "apigateway:DELETE",
      "apigateway:POST"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CreateRolesForGitHubActionsAndTerraform"
    effect = "Allow"
    actions = [
      "iam:DeleteOpenIDConnectProvider",
      "iam:DeleteRole",
      "iam:DeletePolicy",
      "iam:DeleteRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListPolicyVersions",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRolePolicy",
      "iam:GetOpenIDConnectProvider",
      "iam:GetRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]
  }
}


resource "aws_iam_policy" "terraform_oidc" {
  policy = data.aws_iam_policy_document.terraform_oidc_permissions.json
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.terraform_oidc_aws_provider.name

  policy_arn = aws_iam_policy.terraform_oidc.arn
}