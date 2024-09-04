output "s3_bucket_website_url" {
  value       = aws_s3_bucket_website_configuration.idn_new_timmy_6.website_endpoint
  description = "The URL of the static site hosted in the S3 bucket"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "The domain name of the CloudFront distribution"
}
