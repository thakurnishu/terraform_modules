resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "s3-oac"
  description                       = "Access control for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Decide behavior based on mode
locals {
  static_allowed_methods  = ["GET", "HEAD"]
  static_cached_methods   = ["GET", "HEAD"]

  api_allowed_methods     = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
  api_cached_methods      = ["GET", "HEAD", "OPTIONS"]

  allowed_methods  = var.distribution_mode == "api" ? local.api_allowed_methods : local.static_allowed_methods
  cached_methods   = var.distribution_mode == "api" ? local.api_cached_methods  : local.static_cached_methods
  forward_query    = var.distribution_mode == "api"
  forward_cookies  = var.distribution_mode == "api" ? "all" : "none"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = var.default_root_object

  origin {
    domain_name              = var.s3_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods  = local.allowed_methods
    cached_methods   = local.cached_methods
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"

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

