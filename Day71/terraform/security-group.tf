resource "aws_security_group" "ansible_workers" {
  name        = "day70-ansible-workers-sg"
  description = "Security group for Day 70 Ansible worker nodes"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from Ansible control node"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.control_private_ip}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "day70-ansible-workers-sg"
  }
}
