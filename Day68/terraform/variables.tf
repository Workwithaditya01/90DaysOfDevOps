variable "aws_region" {
  description = "AWS region where the Ansible lab will be created"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name used for the Ansible lab resources"
  type        = string
  default     = "day68-ansible"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Your public IP/CIDR allowed to SSH into the control node"
  type        = string
}

variable "ubuntu_ami" {
  description = "Ubuntu AMI ID for the EC2 instances"
  type        = string
}