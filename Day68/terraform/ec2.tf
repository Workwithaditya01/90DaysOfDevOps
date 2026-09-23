resource "aws_instance" "control" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.control.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-control"
    Role = "control"
  }
}


resource "aws_instance" "web" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[1]
  vpc_security_group_ids      = [aws_security_group.managed.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-web"
    Role = "web"
  }
}


resource "aws_instance" "app" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[2]
  vpc_security_group_ids      = [aws_security_group.managed.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-app"
    Role = "app"
  }
}


resource "aws_instance" "db" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.managed.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-db"
    Role = "db"
  }
}