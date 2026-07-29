terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-devops-portfolio-charles-devops-2026"
    key            = "project-03-jenkins-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-charles-devops"
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins" {
  name        = "jenkins-docker-sg"
  description = "Security group for Jenkins Docker server"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-docker-sg"
  }
}

# IAM Role for EC2
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-docker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_admin" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-docker-profile"
  role = aws_iam_role.jenkins_role.name
}

# EC2 Instance
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name
  key_name               = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update and install Docker
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Add ec2-user to docker group
              usermod -aG docker ec2-user

              # Create Jenkins directory
              mkdir -p /opt/jenkins
              chown -R ec2-user:ec2-user /opt/jenkins

              echo "Docker installation complete" > /var/log/docker-install.log
              EOF

  tags = {
    Name = "jenkins-docker-server"
  }
}