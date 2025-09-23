locals {
  # Determine if OAC is needed
  use_oac = var.origin_type == "s3"

  # Cache / methods settings
  static_allowed_methods  = ["GET", "HEAD"]
  static_cached_methods   = ["GET", "HEAD"]

  api_allowed_methods     = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
  api_cached_methods      = ["GET", "HEAD", "OPTIONS"]

  # For website origin, only GET/HEAD are allowed
  allowed_methods  = var.origin_type == "s3_website" ? local.static_allowed_methods : (var.distribution_mode == "api" ? local.api_allowed_methods : local.static_allowed_methods)
  cached_methods   = var.origin_type == "s3_website" ? local.static_cached_methods  : (var.distribution_mode == "api" ? local.api_cached_methods  : local.static_cached_methods)
  
  forward_query    = var.origin_type == "s3_website" ? false : var.distribution_mode == "api"
  forward_cookies  = var.origin_type == "s3_website" ? "none"  : (var.distribution_mode == "api" ? "all" : "none")
}

# Only create OAC if using bucket (not website)
resource "aws_cloudfront_origin_access_control" "this" {
  count                             = local.use_oac ? 1 : 0
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = var.default_root_object

  origin {
    domain_name = var.origin_type == "s3_website" ? var.s3_website_domain_name : var.s3_domain_name
    origin_id   = "s3-origin"

    # OAC only for bucket
    dynamic "origin_access_control_id" {
      for_each = local.use_oac ? [1] : []
      content {
        origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = local.allowed_methods
    cached_methods   = local.cached_methods
    target_origin_id = "s3-origin"

    viewer_protocol_policy = var.origin_type == "s3_website" ? "redirect-to-https" : "redirect-to-https"

    forwarded_values {
      query_string = local.forward_query
      cookies {
        forward = local.forward_cookies
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Only apply bucket policy if using OAC (S3 bucket, not website)
resource "aws_s3_bucket_policy" "oac_policy" {
  count = local.use_oac && !var.public_read_access ? 1 : 0

  bucket = var.s3_bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}
