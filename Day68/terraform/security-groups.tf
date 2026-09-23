resource "aws_security_group" "control" {
  name        = "${var.project_name}-control-sg"
  description = "Security group for Ansible control node"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-control-sg"
  }
}


resource "aws_security_group" "managed" {
  name        = "${var.project_name}-managed-sg"
  description = "Security group for Ansible managed nodes"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "SSH from Ansible control node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.control.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-managed-sg"
  }
}