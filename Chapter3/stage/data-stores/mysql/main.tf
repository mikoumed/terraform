provider "aws" {
    region = "us-east-2"
}

resource "aws_db_instance" "example" {
    identifier_prefix   = "terraform-up-and-running"
    engine              = "mysql"
    allocated_storage   = 10
    instance_class      = "db.t2.micro"
    name                = "mydb"
    username            = "mikoudb"

    # How should we set the password?
    password            = data.aws_secretsmanager_secret_version.db_password.secret_string
    skip_final_snapshot = true
}

data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = "my_first_db_secret"
    }

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "a-terraform-state-s3"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "my-terraform-locks-dynamoDB"
    encrypt        = true
  }
}