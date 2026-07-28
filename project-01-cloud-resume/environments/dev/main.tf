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

# S3 Bucket
module "s3_website" {
  source = "../../modules/s3-website"

  bucket_name = "${local.project}-${local.environment}-website-charles-2026"
  tags        = local.common_tags
}

# DynamoDB Table
module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name = "${local.project}-${local.environment}-visits"
  hash_key   = "id"
  tags       = local.common_tags
}

# Lambda Function
module "lambda" {
  source = "../../modules/lambda"

  function_name = "${local.project}-${local.environment}-counter"
  handler       = "lambda.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/src/lambda.zip"
  dynamodb_table_arn = module.dynamodb.table_arn

  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
  }

  tags = local.common_tags
}

# API Gateway
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name           = "${local.project}-${local.environment}-api"
  project_name       = local.project
  resource_path      = "visits"
  http_method        = "GET"
  lambda_invoke_arn  = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
  stage_name         = local.environment
  tags               = local.common_tags
}

# CloudFront CDN
module "cloudfront" {
  source = "../../modules/cloudfront"

  bucket_name                    = module.s3_website.bucket_id
  s3_bucket_regional_domain_name = module.s3_website.bucket_regional_domain_name
  s3_bucket_arn                  = module.s3_website.bucket_arn
  s3_bucket_id                   = module.s3_website.bucket_id
  project_name                   = local.project
  tags                           = local.common_tags
}