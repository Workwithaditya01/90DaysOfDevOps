output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "db_public_ip" {
  value = aws_instance.db.public_ip
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}
