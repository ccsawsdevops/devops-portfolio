terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-devops-portfolio-charles-devops-2026"
    key            = "project-02-networking-lab/environments/dev/terraform.tfstate"
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
  project     = "networking-lab"
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
  }
}

# VPC 1
module "vpc1" {
  source = "../../modules/vpc"

  cidr_block   = "10.0.0.0/16"
  project_name = local.project
  environment  = local.environment
  tags         = local.common_tags
}

module "vpc1_public_subnet" {
  source                  = "../../modules/subnet"
  vpc_id                  = module.vpc1.vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  subnet_type             = "public"
  map_public_ip_on_launch = true
  project_name            = local.project
  environment             = local.environment
  tags                    = local.common_tags
}

module "vpc1_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc1.vpc_id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  subnet_type       = "private"
  project_name      = local.project
  environment       = local.environment
  tags              = local.common_tags
}

module "vpc1_nat" {
  source           = "../../modules/nat-gateway"
  public_subnet_id = module.vpc1_public_subnet.subnet_id
  project_name     = local.project
  environment      = local.environment
}

# Add route for private subnet through NAT
resource "aws_route" "private_nat" {
  route_table_id         = module.vpc1_private_subnet.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc1_nat.nat_gateway_id
}

# Add route for public subnet through IGW
resource "aws_route" "public_igw" {
  route_table_id         = module.vpc1_public_subnet.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc1.igw_id
}

# VPC 2
module "vpc2" {
  source = "../../modules/vpc"

  cidr_block   = "10.1.0.0/16"
  project_name = local.project
  environment  = local.environment
  tags         = local.common_tags
}

module "vpc2_public_subnet" {
  source                  = "../../modules/subnet"
  vpc_id                  = module.vpc2.vpc_id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1b"
  subnet_type             = "public"
  map_public_ip_on_launch = true
  project_name            = local.project
  environment             = local.environment
  tags                    = local.common_tags
}

module "vpc2_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc2.vpc_id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1b"
  subnet_type       = "private"
  project_name      = local.project
  environment       = local.environment
  tags              = local.common_tags
}

# Transit Gateway
module "tgw" {
  source = "../../modules/transit-gateway"

  project_name = local.project
  environment  = local.environment

  vpc_attachments = {
    vpc1 = {
      vpc_id     = module.vpc1.vpc_id
      subnet_ids = [module.vpc1_private_subnet.subnet_id]
    }
    vpc2 = {
      vpc_id     = module.vpc2.vpc_id
      subnet_ids = [module.vpc2_private_subnet.subnet_id]
    }
  }
}

# Add TGW routes
resource "aws_route" "vpc1_to_vpc2" {
  route_table_id         = module.vpc1_private_subnet.route_table_id
  destination_cidr_block = module.vpc2.vpc_cidr
  transit_gateway_id     = module.tgw.transit_gateway_id
}

resource "aws_route" "vpc2_to_vpc1" {
  route_table_id         = module.vpc2_private_subnet.route_table_id
  destination_cidr_block = module.vpc1.vpc_cidr
  transit_gateway_id     = module.tgw.transit_gateway_id
}

# VPN (simulated with your public IP)
module "vpn" {
  source = "../../modules/vpn"

  customer_ip  = "189.203.231.203"  # Your IP - replace if changed
  vpc_id       = module.vpc1.vpc_id
  project_name = local.project
  environment  = local.environment
}