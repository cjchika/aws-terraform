resource "random_id" "bucket_suffix" {
  byte_length = 5
}

resource "aws_s3_bucket" "job_app" {
  bucket = "job-app-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "React Files"
  })
}

resource "aws_s3_bucket_policy" "job_app_bucket_policy" {
  bucket = aws_s3_bucket.job_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.job_app.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "job_app_block_access" {
  bucket = aws_s3_bucket.job_app.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.job_app.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.job_app.bucket
}
