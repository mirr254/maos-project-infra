provider "aws" {
  region  = var.region
}
terraform {
  backend  "s3" {
    bucket        = "seventh-ave-production-tfstate-store"
    key           = "global/s3/terraform.tfstate"
    region        = "us-east-1"

    dynamodb_table  = "seventh-ave-production-tfstate-locks"
    encrypt         = true
  }
}
