resource "aws_s3_bucket" "gameshop_bucket" {
  bucket = "my-gameshop-bucket"  
  # acl    = "private"

  versioning {
    enabled = true  
  }

  tags = {
    Name        = "My gameshop Bucket"
    Environment = "Production"
  }
}
locals {
  frontend_build_dir = "/home/dhruvrajsinh/Desktop/gaming/client/dist"
}

resource "aws_s3_bucket_object" "frontend_build_files" {
  for_each = fileset(local.frontend_build_dir, "**/*")  # Upload all files and subdirectories recursively

  bucket = aws_s3_bucket.gameshop_bucket.bucket
  key    = "frontend_build/${each.value}"
  content = file("${local.frontend_build_dir}/${each.value}")
  # source = "${local.frontend_build_dir}/${each.value}"
  acl    = "private"  # Set appropriate ACL for your use case
}

# Create cloud front distrubation
resource "aws_cloudfront_distribution" "gameshop_distribution" {
  origin {
    domain_name = aws_s3_bucket.gameshop_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Gameshop distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Add other cache behaviors if needed

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "My Gameshop CloudFront"
    Environment = "Production"
  }
}
