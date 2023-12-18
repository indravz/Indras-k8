provider "aws" {
  region = "us-east-2"
}


terraform {
  backend "local" {
    path = "/Users/reddyin/Documents/Terraform/statefile.tfstate"
  }
}
