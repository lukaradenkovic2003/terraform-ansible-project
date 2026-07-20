resource "aws_s3_bucket" "static_content" {
  bucket = var.s3_bucket_name
  tags = {
    Name    = var.s3_bucket_name
    Project = var.PROJECT
  }
}