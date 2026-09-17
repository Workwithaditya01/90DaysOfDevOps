output "environment" {
  description = "Current Terraform workspace / environment name"
  value       = local.environment
}

output "vpc_id" {
  description = "ID of this environment's VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "ID of this environment's public subnet"
  value       = module.vpc.subnet_id
}

output "security_group_id" {
  description = "ID of this environment's security group"
  value       = module.security_group.sg_id
}

output "instance_id" {
  description = "ID of this environment's EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "instance_public_ip" {
  description = "Public IP of this environment's EC2 instance"
  value       = module.ec2_instance.public_ip
}

