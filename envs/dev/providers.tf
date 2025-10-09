terraform {
  backend "s3" {
    bucket         = "712-tfstate-kevtp"
    key            = "./terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "tfstate-table-prueba"
  }
}

provider "aws" {

}
