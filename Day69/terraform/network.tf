resource "aws_vpc" "day69" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "day69-ansible-vpc"
  }
}

resource "aws_internet_gateway" "day69" {
  vpc_id = aws_vpc.day69.id

  tags = {
    Name = "day69-internet-gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.day69.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "day69-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.day69.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.day69.id
  }

  tags = {
    Name = "day69-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
