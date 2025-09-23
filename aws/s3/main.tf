resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


resource "aws_s3_bucket_website_configuration" "example" {
  count = var.static_website_enabled ? 1 : 0 
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = !(var.public_read_access || var.static_website_enabled)
  block_public_policy     = !(var.public_read_access || var.static_website_enabled)
  ignore_public_acls      = !(var.public_read_access || var.static_website_enabled)
  restrict_public_buckets = !(var.public_read_access || var.static_website_enabled)
}

# Public policy if enabled
resource "aws_s3_bucket_policy" "public" {
  count = (var.public_read_access || var.static_website_enabled) ? 1 : 0 

  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}
