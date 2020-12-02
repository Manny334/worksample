terraform {
  required_version = ">=0.12"
}

# Local variable for s3 resources

locals{
  cors_key = keys(var.s3_cors_configuration) 
}

# ---- s3 bucket ----
resource "aws_s3_bucket" "cdn_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  force_destroy = var.s3_force_destroy

  #CORS configuration. Allowed_methods and allowed_origins are the minimum required fields
  dynamic "cors_rule"{
    for_each = contains(local.cors_key, "allowed_methods") && contains(local.cors_key, "allowed_origins") ? ["1"] : []
    content {
      allowed_methods = lookup(var.s3_cors_configuration, "allowed_methods", null)
      allowed_origins = lookup(var.s3_cors_configuration, "allowed_origins", null)
      max_age_seconds = lookup(var.s3_cors_configuration, "max_age_seconds", null)
      allowed_headers = lookup(var.s3_cors_configuration, "allowed_headers", null)
    }
  }

  tags = {
    Name = "test-bucket"
  }
  versioning {
    enabled = true
  }
}

# Restricting public access to the bucket 
resource "aws_s3_bucket_public_access_block" "cdn_bucket" {
  bucket = aws_s3_bucket.cdn_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  s3_origin_id = "mys3origin"
}

# OAI creation
resource "aws_cloudfront_origin_access_identity" "s3_cloudfront" {
  comment = "OAI for ${aws_s3_bucket.cdn_bucket.bucket_regional_domain_name}"
}
# Bucket Policy 
resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.cdn_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.s3_cloudfront.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": ["${aws_s3_bucket.cdn_bucket.arn}/*"]
        }
    ]
}
 EOF
}

#Assigning s3 bucket as distribution
resource "aws_cloudfront_distribution" "cdn_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.cdn_bucket.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.cdn_bucket.id}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_cloudfront.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  ordered_cache_behavior {
    path_pattern     = "private/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${aws_s3_bucket.cdn_bucket.id}"
    trusted_signers = var.trusted_signers
    

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 3600
  }
  ordered_cache_behavior {
    path_pattern     = "public/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${aws_s3_bucket.cdn_bucket.id}"
    trusted_signers = var.trusted_signers
    

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 3600
  }
  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.cdn_bucket.id}"
    trusted_signers = var.trusted_signers

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 3600
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