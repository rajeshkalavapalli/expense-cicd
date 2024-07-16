terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
   backend "s3" {
    bucket = "vpc-p"
    key    = "jen"
    region = "us-east-1"
    dynamodb_table = "expense-dev"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}