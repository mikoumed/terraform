#Enable remote state storage
provider "aws" {
  region = "us-east-2"
}

#create S3 bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = "a-terraform-state-s3"

  #Prevent accidental deletion of this S3 bucket
  lifecycle {
      prevent_destroy = true
  }

  #Enable versioning so we can see the full revision history of our state files
  versioning {
      enabled = true
  }

  #Enable server-side encryption by default
  server_side_encryption_configuration {
      rule {
          apply_server_side_encryption_by_default {
              sse_algorithm = "AES256"
          }
      }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "my-terraform-locks-dynamoDB"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  
  attribute {
      name = "LockID"
      type = "S"
  }
}

terraform {
    backend "s3" {
        bucket = "a-terraform-state-s3"
        key = "global/s3/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "my-terraform-locks-dynamoDB"
        encrypt = true
    }
}


