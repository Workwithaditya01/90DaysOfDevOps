variable "project_name" {
  description = "Project name used for naming and tagging all resources"
  type        = string
  default     = "terraweek"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the environment's VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the environment's public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for this environment"
  type        = string
}

variable "ingress_ports" {
  description = "List of TCP ports to allow inbound to the instance"
  type        = list(number)
  default     = [22, 80]
}
