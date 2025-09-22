resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public access block depends on public_read_access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = var.public_read_access ? false : true
  block_public_policy     = var.public_read_access ? false : true
  ignore_public_acls      = var.public_read_access ? false : true
  restrict_public_buckets = var.public_read_access ? false : true
}

# Only attach policy if public_read_access is true
resource "aws_s3_bucket_policy" "policy" {
  count = var.public_read_access ? 1 : 0

  bucket = aws_s3_bucket.s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3.arn}/*"
      }
    ]
  })
}
