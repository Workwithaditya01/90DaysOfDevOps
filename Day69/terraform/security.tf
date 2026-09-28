resource "aws_security_group" "managed" {
  name        = "day69-managed-servers"
  description = "Security group for Day 69 Ansible managed servers"
  vpc_id      = aws_vpc.day69.id

  ingress {
    description = "SSH from Ansible control node"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "day69-managed-sg"
  }
}
