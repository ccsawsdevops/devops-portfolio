# Define el proveedor de AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Crea una instancia EC2
resource "aws_instance" "mi_primera_instancia" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 en us-east-1
  instance_type = "t2.micro"

  tags = {
    Name        = "Terraform-Day2"
    Environment = "Learning"
    Project     = "Cloud-Resume"
  }
}
