output "worker_public_ips" {
  description = "Public IP addresses of Ansible workers"

  value = {
    for name, instance in aws_instance.worker :
    name => instance.public_ip
  }
}

output "worker_private_ips" {
  description = "Private IP addresses of Ansible workers"

  value = {
    for name, instance in aws_instance.worker :
    name => instance.private_ip
  }
}

output "worker_instance_ids" {
  description = "EC2 instance IDs"

  value = {
    for name, instance in aws_instance.worker :
    name => instance.id
  }
}
