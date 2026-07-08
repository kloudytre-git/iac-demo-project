# S3 bucket that will hold Terraform state for the main project
resource "aws_s3_bucket" "tfstate" {
  bucket = "kloudy-tfstate-2026"

  tags = {
    project = "iac-portfolio"
    purpose = "terraform-remote-state"
  }
}

# Keep every version of the state file (lets you recover from mistakes)
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt the state at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# State files can contain secrets — block all public access
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking (prevents two applies at once)
resource "aws_dynamodb_table" "tflocks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    project = "iac-portfolio"
    purpose = "terraform-state-locking"
  }
}