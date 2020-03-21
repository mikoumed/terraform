provider "aws" {
    region = "us-east-1"
}

resource "aws_db_instance" "mydbinstance" {
    identifier_prefix   = "terraform-up-and-running"
    engine              = "mysql"
    allocated_storage   = 10
    instance_class      = "db.t2.micro"
    name                = "mydb"
    username            = "mikoudb"
    password = "mypassword"
    skip_final_snapshot = true

}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "a-terraform-state-s3"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "my-terraform-locks-dynamoDB"
    encrypt        = true
  }
}