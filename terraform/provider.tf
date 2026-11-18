terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project = "smart-construction"
      group   = "grupo-13"
      managed = "terraform"
    }
  }
}