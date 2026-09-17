variable "vpc_id" {
  description = "VPC ID the security group belongs to"
  type        = string
}

variable "ingress_ports" {
  description = "List of TCP ports to allow inbound"
  type        = list(number)
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}