
resource "aws_s3_bucket" "React_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "TinuTaskManager_bucket"
  }
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "React_Bucket_website_confg" {
  bucket = aws_s3_bucket.React_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "React_bucket_Acl" {
  bucket = aws_s3_bucket.React_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}




resource "aws_s3_bucket_policy" "React_bucket_policy" {
  bucket = var.bucket_name
  policy = templatefile("./bucket_policy.json", {
    bucket_name     = aws_s3_bucket.React_bucket.id
    account_id      = data.aws_caller_identity.current.account_id
    distribution_id = aws_cloudfront_distribution.s3_distribution.id
  })
  depends_on = [aws_s3_bucket_public_access_block.React_bucket_Acl]
}



data "aws_caller_identity" "current" {}

resource "terraform_data" "always_invalidate_cloudfront" {
  # This triggers the resource to always replace by using a random ID
  triggers_replace = timestamp()

  provisioner "local-exec" {
    command     = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.s3_distribution.id} --paths /*"
    
  }
}