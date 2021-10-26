terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configuring the aws provider

provider "aws" {
  region = var.ntier_region
}
