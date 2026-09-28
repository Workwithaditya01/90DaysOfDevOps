resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.managed.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "day69-web-server"
    Role = "web"
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.managed.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "day69-app-server"
    Role = "app"
  }
}

resource "aws_instance" "db" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.managed.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "day69-db-server"
    Role = "db"
  }
}
