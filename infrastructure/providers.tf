# AWS Provider configuration
provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.14.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.10.0"
    }
  }
}