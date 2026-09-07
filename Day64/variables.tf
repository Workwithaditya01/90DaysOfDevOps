variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}


variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraweek"
}


variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}


variable "allowed_ports" {
  description = "Ports allowed through the security group"
  type        = list(number)

  default = [
    22,
    80,
    443
  ]
}


locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
