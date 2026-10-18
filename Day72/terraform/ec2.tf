resource "aws_instance" "managed_nodes" {
  for_each = {
    web = {
      name = "Day72-worker-Node"
      role = "web"
      }
  }

  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ansible_managed.id]
  key_name               = var.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name        = each.value.name
    Role        = each.value.role
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
    Ansible     = "true"
  }
}
