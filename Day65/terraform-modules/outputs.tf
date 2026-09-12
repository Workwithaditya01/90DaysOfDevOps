output "web_server_ip" {
  description = "Public IP address of the web server"
  value       = module.web_server.public_ip
}

output "api_server_ip" {
  description = "Public IP address of the API server"
  value       = module.api_server.public_ip
}

output "security_group_id" {
  description = "Web security group ID"
  value       = module.web_sg.sg_id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}