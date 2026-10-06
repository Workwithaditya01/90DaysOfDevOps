output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.managed_nodes["web"].public_ip
}

output "web_private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.managed_nodes["web"].private_ip
}

output "app_public_ip" {
  description = "Public IP of the app server"
  value       = aws_instance.managed_nodes["app"].public_ip
}

output "app_private_ip" {
  description = "Private IP of the app server"
  value       = aws_instance.managed_nodes["app"].private_ip
}

output "db_public_ip" {
  description = "Public IP of the DB server"
  value       = aws_instance.managed_nodes["db"].public_ip
}

output "db_private_ip" {
  description = "Private IP of the DB server"
  value       = aws_instance.managed_nodes["db"].private_ip
}

output "managed_nodes" {
  description = "Managed node information"

  value = {
    for role, instance in aws_instance.managed_nodes : role => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      hostname   = instance.tags.Name
    }
  }
}
