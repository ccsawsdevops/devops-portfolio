variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "my_ip" {
  description = "Your public IP address with CIDR (e.g., 203.0.113.0/32)"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}