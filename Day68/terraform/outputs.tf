output "control_public_ip" {
  description = "Public IP of the Ansible control node"
  value       = aws_instance.control.public_ip
}

output "control_private_ip" {
  description = "Private IP of the Ansible control node"
  value       = aws_instance.control.private_ip
}

output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "web_private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.web.private_ip
}

output "app_public_ip" {
  description = "Public IP of the app server"
  value       = aws_instance.app.public_ip
}

output "app_private_ip" {
  description = "Private IP of the app server"
  value       = aws_instance.app.private_ip
}

output "db_public_ip" {
  description = "Public IP of the database server"
  value       = aws_instance.db.public_ip
}

output "db_private_ip" {
  description = "Private IP of the database server"
  value       = aws_instance.db.private_ip
}