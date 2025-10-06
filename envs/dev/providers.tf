terraform {
  backend "s3" {
    bucket = "712-tfstate-kevtp"
    key = "./terraform.tfstate"
    region = "us-east-2"
    encrypt = true
    dynamodb_table = "tfstate-table-prueba"
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}