# TODO: Group permissions by modules created by root template

data "aws_caller_identity" "current" {}


##### SECTION - Setting up the OIDC provider (Terraform)
data "tls_certificate" "provider" {
  url = "https://app.terraform.io"
}

resource "aws_iam_openid_connect_provider" "hcp_terraform" {
  url = "https://app.terraform.io"

  client_id_list = [
    "aws.workload.identity", # Default audience in HCP Terraform for AWS.
  ]

  thumbprint_list = [
    data.tls_certificate.provider.certificates[0].sha1_fingerprint,
  ]
}
##### END SECTION #####


##### SECTION - Create role that Terraform will assume at runtime
data "aws_iam_policy_document" "oidcprovider_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.hcp_terraform.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:${var.my_terraform_org}:project:${var.terraform_project_name}:workspace:${var.terraform_deploy_workspace}:run_phase:${var.terraform_workspace-run_phase}"]
    }

  }
}

resource "aws_iam_role" "terraform_oidc_aws_provider" {
  description = "Role for Terraform to assume to create the app infrastructure"

  name = "TerraformAWSAccess"

  assume_role_policy = data.aws_iam_policy_document.oidcprovider_assume_role.json
}

# Adding permissions
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
      "dynamodb:CreateTable",
      "dynamodb:ListTagsOfResource"
    ]
    resources = ["*"]
    # arn:aws:dynamodb:<region>:<acct id>:table/VisitorCounterTable 
  }

  statement {
    sid    = "statement3"
    effect = "Allow"
    actions = [
      "s3:DeleteBucket",
      "s3:GetBucketPolicy",
      "s3:GetBucketTagging",
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
      "s3:CreateBucket",
      "s3:ListBucket"
    ]

    resources = ["*"]
    # arn's of possibly multiple:
    #   module.s3-cloudfront-static-site-hsts.aws_s3_bucket.frontend_bucket
    #   or arn:aws:s3:::terraform-*
  }

  statement {
    sid    = "Statement4"
    effect = "Allow"
    actions = [
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "acm:RequestCertificate",
      "acm:ListTagsForCertificate"
    ]

    resources = ["*"]
    # awn of module.route53-cloudfront-alias-w-ssl-validation.aws_acm_certificate.ssl_cert
  }

  statement {
    sid    = "Statement5"
    effect = "Allow"
    actions = [
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:DeleteResponseHeadersPolicy",
      "cloudfront:DeleteDistribution",
      "cloudfront:UpdateDistribution",
      "cloudfront:UpdateResponseHeadersPolicy",
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetDistribution",
      "cloudfront:CreateResponseHeadersPolicy",
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:CreateDistribution",
      "cloudfront:ListTagsForResource",
      "cloudfront:TagResource"
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
      "logs:DescribeLogGroups",
      "logs:CreateLogGroup",
      "logs:CreateLogDelivery",
      "logs:PutRetentionPolicy",
      "logs:ListTagsForResource",
      "logs:ListLogDeliveries",
      "logs:DeleteLogDelivery"
    ]

    resources = ["*"]
    # arn:aws:logs:us-east-1:651706758768:log-group::log-stream:(* ? not sure)
  }

  statement {
    sid    = "Statement9"
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Statement10"
    effect = "Allow"
    actions = [
      "ssm:DeleteParameter",
      "ssm:DescribeParameters",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:PutParameter",
      "ssm:ListTagsForResource"
    ]

    resources = ["*"]
    # arn:aws:ssm:<aws-region>:<acct id>:parameter/SLACK_WEBHOOK_URL
  }

  statement {
    sid    = "Statement11"
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:GetSubscriptionAttributes",
      "sns:SetTopicAttributes",
      "sns:GetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:Unsubscribe",
      "sns:Subscribe"
    ]

    resources = [
      "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
      # arn:aws:sns:<region>:<acct id>:[5xxApiResponse, 4xxApiResponse, ...need to populate]
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
      "lambda:CreateFunction",
      "lambda:TagResource",
      "lambda:UpdateFunctionCode"
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
      "iam:DeletePolicyVersion",
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
      "iam:PassRole",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreateServiceLinkedRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:CreatePolicyVersion"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_oidc" {
  policy = data.aws_iam_policy_document.terraform_oidc_permissions.json
}

resource "aws_iam_role_policy_attachment" "terraform_permissions" {
  role = aws_iam_role.terraform_oidc_aws_provider.name

  policy_arn = aws_iam_policy.terraform_oidc.arn
}
##### END SECTION #####


##### SECTION - Create the workspace for infrastructure deployment
data "tfe_project" "tfc_project" {
  name         = var.terraform_project_name
  organization = var.my_terraform_org
}

resource "tfe_workspace" "my_workspace" {
  name         = var.terraform_deploy_workspace
  organization = var.my_terraform_org
  project_id   = data.tfe_project.tfc_project.id
}
#### END SECTION #####


##### SECTION - Passing env to another workspace so it can use OIDC federation #####
resource "tfe_variable" "tfc_aws_provider_auth" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.my_workspace.id
}

resource "tfe_variable" "tfc_example_role_arn" {
  sensitive    = true
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = aws_iam_role.terraform_oidc_aws_provider.arn
  category     = "env"
  workspace_id = tfe_workspace.my_workspace.id
}