
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
  default     = "ansible-practice-key"
}

variable "control_private_ip" {
  description = "Private IP address of the existing Ansible control node"
  type        = string
  default     = "172.31.0.50"
}
