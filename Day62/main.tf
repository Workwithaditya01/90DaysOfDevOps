
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraweek-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Terraweek-Public-RT"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "main" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP Traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraweek-SG"
  }
}

resource "aws_instance" "main" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "TerraWeek-Server"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket_prefix = "terraweek-app-logs-"

  depends_on = [aws_instance.main]

  tags = {
    Name = "TerraWeek-App-Logs"
  }
}


