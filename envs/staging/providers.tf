terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "kloudy-tfstate-2026"            # SAME as dev
    key            = "envs/staging/terraform.tfstate" # <-- CHANGED (was envs/dev/...)
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" # SAME as dev
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}