# This module sets up AWS IAM permission policy for the visitor counter module
# , and attach it to a pre-created role for GitHub Actions
# https://aws.amazon.com/blogs/apn/simplify-and-secure-terraform-workflows-on-aws-with-dynamic-provider-credentials/

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ghactions_sam" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    sid     = "S3_SAMBucketAccess"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.sam_artifacts_bucket.arn
      # TODO (Necessary??): Get ARN of S3 bucket storing templates used (not sure if necessary with Terraform)
    ]
  }

  statement {
    effect = "Allow"
    sid    = "CloudFormation_ChangeSetPermissions"
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
    sid    = "CloudFormationPermissions"

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

  statement {
    effect = "Allow"
    sid    = "SAM_LogGroupPermission"

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
    sid    = "SAM_CreateLogDelivery"

    actions = ["logs:CreateLogDelivery"]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    sid    = "SAM_DynamoDBPermission"

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

    resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/*"]
  }

  statement {
    effect = "Allow"
    sid    = "SAM_RoleCreationPermission"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagRole"
    ]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.SAM_stack_name}*"]
  }

  statement {
    effect = "Allow"
    sid    = "SAM_AllowCreateServiceRoles"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ops.apigateway.amazonaws.com/AWSServiceRoleForAPIGateway"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "AllowGHRoleToGetInfoOnSelf"

    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ghactions_aws_role_arn}"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "SAM_LambdaPermission"

    actions = [
      "lambda:GetFunction",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:TagResource",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:GetRuntimeManagementConfig",
      "lambda:GetFunctionCodeSigningConfig"
    ]

    resources = ["arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.SAM_stack_name}*"]
  }

  statement {
    effect = "Allow"
    sid    = "ApiGwPermission"

    actions = [
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:TagResource"
    ]

    resources = ["arn:aws:apigateway:${var.aws_region}::*"]
  }

  statement {
    effect = "Allow"
    sid    = "SAM_SNSPermissions"

    actions = [
      "SNS:CreateTopic",
      "sns:GetTopicAttributes",
      "SNS:GetDataProtectionPolicy",
      "sns:SetTopicAttributes",
      "sns:Subscribe",
      "SNS:ListTagsForResource",
      "SNS:ListSubscriptionsByTopic"
    ]

    resources = [
      "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "CWPermissions"

    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm"
    ]

    resources = [
      "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:*"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "CFnPermissions"

    actions = [
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:UpdateResponseHeadersPolicy"
    ]

    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:response-headers-policy/${var.cfdistro_response_headers_policy_id}"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "GetCfnDistroOAC"

    actions = [
      "cloudfront:GetOriginAccessControl"
    ]

    resources = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:origin-access-control/${var.cfdistro_oac_id}"]
  }

  statement {
    effect = "Allow"
    sid    = "SAM_CfnDistroPermission"

    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:CreateInvalidation"
    ]

    resources = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cfdistro_id}"]

  }
}

# create bucket so SAM running from GHActions can consistently store to. helps w/ automation?
resource "aws_s3_bucket" "sam_artifacts_bucket" {}

resource "aws_iam_role_policy" "ghactions_sam_permission_policy" {
  role = var.ghactions_aws_role_arn

  policy = data.aws_iam_policy_document.ghactions_sam.json

  name = "GHActions-SAM-Policy"
}