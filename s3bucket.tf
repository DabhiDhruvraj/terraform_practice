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