locals {
  workers = {
    web = {
      name = "day70-web"
    }

    app = {
      name = "day70-app"
    }

    db = {
      name = "day70-db"
    }
  }
}

resource "aws_instance" "worker" {
  for_each = local.workers

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [
    aws_security_group.ansible_workers.id
  ]

  associate_public_ip_address = true

  tags = {
    Name = each.value.name
    Role = each.key
  }
}
