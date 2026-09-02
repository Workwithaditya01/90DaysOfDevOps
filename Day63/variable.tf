variable "region"{
  description = "AWS region"
  type = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for public subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.micro"
}

variable "Project Name" {
  description = "Name of the Project"
  type = string
}

variable "environment" {
  description = "Deployment Environment"
  type = string
  default = "dev"
}

variable "allowed_ports" {
  description = "Port allowed throught security groups"
  type = list(number)
  default = [ 22, 80, 443 ]
}

variable "extra tags" {
  description = "Additional tags"
  type = map(string)
  default = {}
}
