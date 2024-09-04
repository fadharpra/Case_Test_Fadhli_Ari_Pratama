resource "aws_route53_record" "www" {
  zone_id = "Z03102443KHY48QVUVSK9"  
  name    = "new-timmy-6.serverless.my.id"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "idn_new_timmy_6" {
  bucket = "idn-new-timmy-6"
}

resource "aws_s3_bucket_website_configuration" "idn_new_timmy_6" {
  bucket = aws_s3_bucket.idn_new_timmy_6.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "idn_new_timmy_6_versioning" {
  bucket = aws_s3_bucket.idn_new_timmy_6.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_s3_bucket" "bucket_new_timmy_idn" {
  bucket = "bucket-new-timmy-idn"  # This is the existing bucket
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  aliases = ["new-timmy-6.serverless.my.id"]

  origin {
    domain_name = aws_s3_bucket.idn_new_timmy_6.bucket_regional_domain_name
    origin_id   = "idn-new-timmy-6"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = data.aws_s3_bucket.bucket_new_timmy_idn.bucket_domain_name
    origin_id   = "bucket-new-timmy-idn"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "idn-new-timmy-6"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/asset-img-broken.png"
    target_origin_id = "bucket-new-timmy-idn"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:166190020492:certificate/1119d63b-db83-4afb-b726-4a8944f6ec7f"
    ssl_support_method              = "sni-only"
    minimum_protocol_version        = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Access identity for CloudFront to S3"
}

