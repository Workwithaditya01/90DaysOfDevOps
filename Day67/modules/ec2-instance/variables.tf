variable "ami_id" {
  description = "AMI ID to launch the instance from"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (sizing differs per environment)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance into"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}
