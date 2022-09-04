provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = "= 1.0.9"

  required_providers {
    aws = "= 3.63.0"
  }

  backend "s3" {
    bucket = "okto-terraform-config"
    key    = "tfstate"
    region = "us-east-1"
  }
}