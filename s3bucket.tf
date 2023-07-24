// Create s3 bucket
resource "aws_s3_bucket" "dhruvraj-gameshop-bucket-s3" {
  bucket = "dhruvraj-gameshop-bucket-s3"
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

// Upload all files to created bucket
resource "aws_s3_bucket_object" "frontend_build_files" {
  bucket = aws_s3_bucket.dhruvraj-gameshop-bucket-s3.id
  for_each = fileset(local.frontend_build_dir, "**/*")
  key = "frontend_build/${each.value}"
  content = file("${local.frontend_build_dir}/${each.value}")
  # source = "build/${each.value}"
  # etag = filemd5("build/${each.value}")
}

// Create an origin access identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for dhruvraj-gameshop-bucket-s3"
}

// Update the bucket policy to only allow the OAI
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.dhruvraj-gameshop-bucket-s3.id
  policy = <<-POLICY
  {
    "Version":"2012-10-17",
    "Statement":[
      {
        "Sid":"PublicReadGetObject",
        "Effect":"Allow",
        "Principal": {
          "AWS": ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"]
        },
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::${aws_s3_bucket.dhruvraj-gameshop-bucket-s3.id}/*"]
      }
    ]
  }
  POLICY
}

// Create cloud front distribution with OAI in the origin
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.dhruvraj-gameshop-bucket-s3.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.dhruvraj-gameshop-bucket-s3.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    // remaining configuration...
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.dhruvraj-gameshop-bucket-s3.bucket_regional_domain_name

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
  }

  // remaining configuration...
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
}

// Output CloudFront distribution URL
output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
