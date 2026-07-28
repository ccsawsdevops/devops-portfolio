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
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"

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
    Name = "jenkins-sg"
  }
}

# IAM Role for Jenkins EC2
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role"

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
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# EC2 Instance for Jenkins
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

              # Update system
              dnf update -y

              # Install Java 17
              dnf install -y java-17-amazon-corretto

              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              dnf install -y jenkins

              # Start Jenkins
              systemctl enable jenkins
              systemctl start jenkins

              # Install Git
              dnf install -y git

              # Install Terraform
              dnf install -y dnf-plugins-core
              dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              dnf install -y terraform

              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -q awscliv2.zip
              ./aws/install
              rm -rf aws awscliv2.zip

              # Install tfsec for security scanning
              curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

              echo "Jenkins installation complete" > /var/log/jenkins-install.log
              EOF

  tags = {
    Name = "jenkins-server"
  }
}