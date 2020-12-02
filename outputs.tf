output "aws_cloudfront_distribution" {
  value = aws_cloudfront_distribution.cdn_distribution
}

output "origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.s3_cloudfront
}

output "aws_s3_bucket" {
  value = aws_s3_bucket.cdn_bucket
}

