terraform {
  required_providers {
    aws = {
      version = "~> 6.18.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
