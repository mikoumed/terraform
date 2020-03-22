provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "a-terraform-state-s3"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
  webserver_remote_state_key = "stage/service/webserver-cluster/terraform.tfstate"
}