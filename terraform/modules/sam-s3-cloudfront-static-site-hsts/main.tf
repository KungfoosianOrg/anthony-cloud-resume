# This module:
#   1. (depends) Creates a Route53 hosted zone for a custom domain
#   2. Creates IPv4 (A) and IPv6 (AAAA) alias records for the domain (and any subdomains), pointing to a CloudFront distribution
#   3. Validates SSL certificate for the custom domain with the Route53 hosted zone
#
#
# Optional parameters:
#   + route53_hosted_zone_id


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

##### PART 1 #####

# Checks iif isi_prod_build defined:
#   yes: ignore this resource creation
#   no : create hosted zone
# resource "aws_route53_zone" "primary" {
#   count = var.is_prod_build ? 0 : 1

#   name = var.registered_domain_name
# }
##### END PART #####

resource "aws_cloudfront_response_headers_policy" "cfdistro_response_headers" {
  name = "${aws_s3_bucket.frontend_bucket.id}_response-header-policy"

  security_headers_config {
    content_security_policy {
      override = true

      content_security_policy = join(";", [
        "default-src 'self' https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
        "base-uri 'self' https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
        "frame-src https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
        "frame-ancestors 'self' https://${var.registered_domain_name} https://*.${var.registered_domain_name}",
        "form-action 'none'",
        "style-src https://${var.registered_domain_name} https://*.${var.registered_domain_name} https://cdn.jsdelivr.net",
        "script-src https://${var.registered_domain_name} https://*.${var.registered_domain_name} https://cdn.jsdelivr.net",
        "connect-src ${var.apigw_endpoint_url == "" ? "none" : var.apigw_endpoint_url}",
        "img-src https://${var.registered_domain_name} https://*.${var.registered_domain_name} data: w3.org/svg/2000"
      ])
    }

    content_type_options {
      override = true
    }

    strict_transport_security {
      override                   = true
      include_subdomains         = true
      preload                    = true
      access_control_max_age_sec = 31536000
    }
  }
}

resource "aws_cloudfront_distribution" "production_distribution" {
  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    compress = true

    target_origin_id = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name

    viewer_protocol_policy = "redirect-to-https"

    response_headers_policy_id = aws_cloudfront_response_headers_policy.cfdistro_response_headers.id
  }

  default_root_object = "index.html"

  enabled = true

  http_version = "http2"

  is_ipv6_enabled = true

  price_class = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name

    origin_id = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.production_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  aliases = concat([var.registered_domain_name], [for subdomain in var.subdomains : "${subdomain}.${var.registered_domain_name}"])

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn

    ssl_support_method = "sni-only"

    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "production_oac" {
  name = "oac-cf-static-page"

  origin_access_control_origin_type = "s3"

  signing_behavior = "always"

  signing_protocol = "sigv4"
}

resource "aws_s3_bucket" "frontend_bucket" {}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_pubaccessblock" {
  bucket = aws_s3_bucket.frontend_bucket.id
}

resource "aws_s3_bucket_versioning" "frontend_bucket_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    # resources = [ join("/", [ aws_s3_bucket.frontend_bucket.arn, "*" ]) ]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]


    condition {
      test = "StringEquals"

      variable = "aws:sourceArn"

      values = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.production_distribution.id}"]
    }
  }
}


resource "aws_iam_role_policy" "ghactions_permission_policy" {
  name = "PermPol_GHActions-S3"

  role = var.ghactions_aws_role_arn

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.frontend_bucket.arn}",
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]

        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetAccelerateConfiguration",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetBucketLogging",
          "s3:GetBucketOwnershipControls",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketNotification",
          "s3:GetIntelligentTieringConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetInventoryConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetAnalyticsConfiguration",
          "s3:GetBucketCORS",
          "s3:GetMetricsConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetBucketTagging",
          "s3:GetBucketWebsite",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketVersioning"
        ]
      },

      {
        Effect = "Allow"

        Resource = "arn:aws:route53:::hostedzone/${var.route53_hosted_zone_id}"

        Action = ["route53:getHostedZone"]
      }
    ]


  })
}