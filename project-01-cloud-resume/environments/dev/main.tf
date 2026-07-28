# environments/dev/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-devops-portfolio-charles-devops-2026"
    key            = "project-01-cloud-resume/environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-charles-devops"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment = "dev"
  project     = "cloud-resume"
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
  }
}

# S3 Website Module
module "s3_website" {
  source = "../../modules/s3-website"

  bucket_name = "${local.project}-${local.environment}-website-charles-2026"
  tags        = local.common_tags
}

# DynamoDB Module
module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name = "${local.project}-${local.environment}-visits"
  hash_key   = "id"
  tags       = local.common_tags
}