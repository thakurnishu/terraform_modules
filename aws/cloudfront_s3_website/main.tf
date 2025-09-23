# S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.this]
}


# Cloudfront
locals {
  // Access Control
  origin_type      = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"

  // distributions
  allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  cached_methods  = ["GET", "HEAD"]
  forward_query   = false
  forward_cookies = "none"

  // cloudfront function
  runtime                = "cloudfront-js-2.0"
  publish                = true
  viewer_protocol_policy = "redirect-to-https"
  geo_restriction_type   = "none"
  function_event_type    = "viewer-request"
}


resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = local.origin_type
  signing_behavior                  = local.signing_behavior
  signing_protocol                  = local.signing_protocol
}


data "aws_acm_certificate" "domain" {
  count = var.enable_custom_domain ? 1 : 0
  region   = var.acm_region
  domain   = var.website_custom_domain
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_function" "url_rewrite" {
  count = var.use_cloudfront_function ? 1 : 0
  name    = "${var.project_name}-url-rewrite"
  runtime = local.runtime
  publish = local.publish
  code    = var.function_code
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = var.default_root_object

  aliases = var.enable_custom_domain ? [var.website_custom_domain] : []

  origin {
    origin_id = "${var.project_name}-origin"

    domain_name              = aws_s3_bucket.this.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods  = local.allowed_methods
    cached_methods   = local.cached_methods
    target_origin_id = "${var.project_name}-origin"

    viewer_protocol_policy = local.viewer_protocol_policy

    forwarded_values {
      query_string = local.forward_query
      cookies {
        forward = local.forward_cookies
      }
    }

    dynamic "function_association" {
      for_each = var.use_cloudfront_function ? [1] : []
      content {
        event_type   = local.function_event_type
        function_arn = aws_cloudfront_function.url_rewrite[0].arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = local.geo_restriction_type
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.enable_custom_domain ? false : true
    acm_certificate_arn = var.enable_custom_domain ? data.aws_acm_certificate.domain[0].arn : null
    ssl_support_method  = var.enable_custom_domain ? "sni-only" : null
    minimum_protocol_version = var.enable_custom_domain ? "TLSv1.2_2021" : null
  }

  tags = var.tags

  depends_on = concat(
    var.enable_custom_domain ? [data.aws_acm_certificate.domain[0]] : [],
    var.use_cloudfront_function ? [aws_cloudfront_function.url_rewrite[0]] : []
  )
}

data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
  depends_on = [aws_s3_bucket.this, aws_cloudfront_distribution.this]
}


# OAC Policy
resource "aws_s3_bucket_policy" "oac_policy" {
  bucket = aws_s3_bucket.this.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json

  depends_on = [data.aws_iam_policy_document.origin_bucket_policy]
}
