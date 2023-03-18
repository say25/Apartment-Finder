terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket  = "terraform-826872761219-us-east-1"
    region  = "us-east-1"
    key     = "apartment-finder-app/terraform.tfstate"
    encrypt = "true"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.tags
  }

  ignore_tags {
    key_prefixes = ["cai:"]
  }
}
