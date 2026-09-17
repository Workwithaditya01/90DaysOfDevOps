# --------------------------------------------------------------------------
# Data sources: pick an AZ and the latest Amazon Linux 2 AMI automatically,
# so environment tfvars only need to specify what actually differs per env.
# --------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --------------------------------------------------------------------------
# VPC module -- one per workspace/environment
# --------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  cidr               = var.vpc_cidr
  public_subnet_cidr = var.subnet_cidr
  environment        = local.environment
  project_name       = var.project_name
  availability_zone  = data.aws_availability_zones.available.names[0]
}

# --------------------------------------------------------------------------
# Security group module -- ingress ports vary per environment
# (dev allows SSH, prod does not; see tfvars)
# --------------------------------------------------------------------------
module "security_group" {
  source = "./modules/security-group"

  vpc_id        = module.vpc.vpc_id
  ingress_ports = var.ingress_ports
  environment   = local.environment
  project_name  = var.project_name
}

# --------------------------------------------------------------------------
# EC2 instance module -- instance_type scales per environment
# --------------------------------------------------------------------------
module "ec2_instance" {
  source = "./modules/ec2-instance"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security_group.sg_id]
  environment        = local.environment
  project_name       = var.project_name
}
