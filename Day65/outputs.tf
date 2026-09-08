output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the first public subnet"
  value       = module.vpc.public_subnets[0]
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = module.web_sg.sg_id
}

output "web_server_id" {
  description = "Web server instance ID"
  value       = module.web_server.instance_id
}

output "web_server_ip" {
  description = "Web server public IP"
  value       = module.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Web server private IP"
  value       = module.web_server.private_ip
}

output "api_server_id" {
  description = "API server instance ID"
  value       = module.api_server.instance_id
}

output "api_server_ip" {
  description = "API server public IP"
  value       = module.api_server.public_ip
}

output "api_server_private_ip" {
  description = "API server private IP"
  value       = module.api_server.private_ip
}
