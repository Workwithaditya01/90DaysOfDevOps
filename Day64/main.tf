terraform {
  backend "s3" {
    bucket         = "terraweek-state-aditya-devops-2026"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "application" {
  bucket = "terraweek-import-aditya-2026"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-subnet"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-route-table"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "main" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name}"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allowed_ports

    content {
      description = "Allow port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-server"
  })
}
