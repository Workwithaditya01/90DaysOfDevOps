# Day 65 — Terraform Modules: Build Reusable Infrastructure

## Objective

The goal of Day 65 was to understand and implement **Terraform Modules** to make infrastructure code reusable, organized, and easier to maintain.

Instead of keeping all infrastructure resources inside one large `main.tf`, I created reusable custom modules for:

- EC2 instances
- Security groups
- VPC infrastructure using an official Terraform Registry module

The final infrastructure contains:

- 1 VPC
- 2 public subnets
- 2 private subnets
- Internet Gateway
- Public and private route tables
- Security Group
- 2 EC2 instances
- Reusable EC2 module
- Reusable Security Group module
- Official VPC Registry module

---

## Task 1 — Understand Terraform Module Structure

The project was organized into a root module and reusable child modules.

```text
terraform-modules/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── modules/
    ├── ec2-instance/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── security-group/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Root Module

The root module is the main Terraform project. It is responsible for:

- Calling child modules
- Providing values to modules
- Connecting modules together
- Managing overall infrastructure

### Child Modules

The child modules contain reusable infrastructure components.

- `ec2-instance` — creates EC2 instances
- `security-group` — creates security groups

This allows the same module to be reused multiple times with different values.

---

## Task 2 — Create Custom EC2 Module

The EC2 module was created inside `modules/ec2-instance/`.

### EC2 Module Variables

The module accepts:

- AMI ID
- Instance type
- Subnet ID
- Security group IDs
- Instance name
- Additional tags

**`variables.tf`**

```hcl
variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet where the EC2 instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Additional tags for the EC2 instance"
  type        = map(string)
  default     = {}
}
```

### EC2 Resource

The module uses the supplied variables to create an EC2 instance.

**`main.tf`**

```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}
```

The `merge()` function combines the instance name with the common project tags.

### EC2 Outputs

**`outputs.tf`**

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}
```

These outputs allow the root module to retrieve information from the EC2 module.

---

## Task 3 — Create Custom Security Group Module

The second custom module was created inside `modules/security-group/`.

The purpose of this module was to create a reusable security group where the allowed ingress ports can be passed as variables.

### Security Group Variables

**`variables.tf`**

```hcl
variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_ports" {
  description = "List of ports allowed for incoming traffic"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}
```

### Security Group Resource

**`main.tf`**

```hcl
resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security group managed by Terraform"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
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

  tags = var.tags
}
```

The `dynamic` block was used so that multiple ingress rules could be generated from a list of ports.

For this project, the following ports were passed to the module:

```text
22
80
443
```

### Security Group Output

**`outputs.tf`**

```hcl
output "sg_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}
```

The output is later used by the EC2 module.

---

## Task 4 — Use Custom Modules from Root Module

The root module calls the custom Security Group module:

```hcl
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}
```

The Security Group ID is then passed to both EC2 modules.

### Web Server

```hcl
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}
```

### API Server

```hcl
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

The important concept here is that the **same EC2 module is reused twice**. The only major differences are:

```text
terraweek-web
terraweek-api
```

This demonstrates how one reusable module can create multiple infrastructure resources.

---

## Task 5 — Replace Hand-Written VPC with Registry Module

Instead of manually creating every VPC resource, I used the official Terraform Registry VPC module:

```text
terraform-aws-modules/vpc/aws
```

The module was configured with version `~> 5.0`.

### VPC Module

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  map_public_ip_on_launch = true

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}
```

The registry module created and managed multiple networking resources instead of requiring every resource to be manually defined.

---

## Task 6 — Connect VPC Module with Custom Modules

The Security Group module now receives the VPC ID from the registry module:

```hcl
vpc_id = module.vpc.vpc_id
```

The EC2 modules receive the first public subnet:

```hcl
subnet_id = module.vpc.public_subnets[0]
```

The overall dependency flow became:

```text
Terraform Root Module
        |
        v
   VPC Module
        |
        +--------------------+
        |                    |
        v                    v
 Security Group         Public Subnet
        |                    |
        +---------+----------+
                  |
                  v
          EC2 Module
          /        \
         v          v
   Web Server    API Server
```

This demonstrates how outputs from one module can become inputs to another module.

---

## Task 7 — Terraform State Migration

Because the VPC resources already existed from the previous Terraform configuration, the existing resources were moved into the new module addresses instead of creating duplicate infrastructure.

The following commands were used:

```bash
terraform state mv 'aws_vpc.main' 'module.vpc.aws_vpc.this[0]'
```

```bash
terraform state mv 'aws_subnet.public' 'module.vpc.aws_subnet.public[0]'
```

```bash
terraform state mv 'aws_internet_gateway.main' 'module.vpc.aws_internet_gateway.this[0]'
```

```bash
terraform state mv 'aws_route_table.public' 'module.vpc.aws_route_table.public[0]'
```

```bash
terraform state mv 'aws_route_table_association.public' 'module.vpc.aws_route_table_association.public[0]'
```

The availability-zone data source was no longer required because the registry module handles the availability zones directly. Therefore it was removed from state:

```bash
terraform state rm 'data.aws_availability_zones.available'
```

---

## Task 8 — Handle Existing Route

During the migration, Terraform detected that the existing public route was already present.

The error was:

```text
RouteAlreadyExists
```

Instead of creating another identical route, the existing route was imported into the Terraform state:

```bash
terraform import 'module.vpc.aws_route.public_internet_gateway[0]' 'rtb-077659a85fd88f5be_0.0.0.0/0'
```

After importing the existing route, Terraform was able to correctly match the real AWS infrastructure with the new module configuration.

---

## Task 9 — Verify Terraform Configuration

The infrastructure was verified using:

```bash
terraform plan
```

The final result was:

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

This confirmed that the infrastructure was successfully reconciled with the new module-based configuration.

---

## Task 10 — Verify Terraform State

The Terraform state was checked using:

```bash
terraform state list
```

Important module resources appeared with module prefixes:

```text
module.api_server.aws_instance.this
module.web_server.aws_instance.this
module.web_sg.aws_security_group.this
module.vpc.aws_vpc.this[0]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]
module.vpc.aws_internet_gateway.this[0]
module.vpc.aws_route_table.public[0]
module.vpc.aws_route_table.private[0]
module.vpc.aws_route_table.private[1]
```

This demonstrated how Terraform tracks resources created through modules.

---

## Task 11 — Terraform Module Versioning

Terraform module versions can be controlled using version constraints.

**Exact Version**

```hcl
version = "5.1.0"
```

This selects exactly version `5.1.0`.

**Minor Version Range**

```hcl
version = "~> 5.0"
```

This allows compatible versions in the 5.x range according to Terraform's pessimistic constraint rules.

**Explicit Range**

```hcl
version = ">= 5.0, < 6.0"
```

This allows versions from 5.0 upward but prevents Terraform from selecting version 6.x.

The project used:

```hcl
version = "~> 5.0"
```

---

## Task 12 — Upgrade Module Versions

Terraform can check for newer allowed provider and module versions using:

```bash
terraform init -upgrade
```

Other useful commands:

```bash
terraform version
```

```bash
terraform providers
```

```bash
terraform state list
```

```bash
terraform plan
```

---

## Task 13 — Final Infrastructure

The final infrastructure consists of:

```text
AWS
│
└── terraweek-vpc
    │
    ├── Public Subnet 1
    │   ├── Web Server
    │   └── API Server
    │
    ├── Public Subnet 2
    │
    ├── Private Subnet 1
    │
    ├── Private Subnet 2
    │
    ├── Internet Gateway
    │
    ├── Public Route Table
    │
    ├── Private Route Tables
    │
    └── Security Group
        ├── SSH : 22
        ├── HTTP : 80
        └── HTTPS : 443
```

The two EC2 instances were created using the same reusable EC2 module:

```text
terraweek-web
terraweek-api
```

Both use:

```text
Instance Type: t3.micro
Region: ap-south-1
```

---

## Task 14 — Root Outputs

The root module exposes useful information from the child modules.

```hcl
output "web_server_ip" {
  description = "Public IP address of the web server"
  value       = module.web_server.public_ip
}

output "api_server_ip" {
  description = "Public IP address of the API server"
  value       = module.api_server.public_ip
}

output "security_group_id" {
  description = "Web security group ID"
  value       = module.web_sg.sg_id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
```

This demonstrates how module outputs can be exposed by the root module.

---

## Task 15 — Terraform Module Best Practices

The following best practices were followed during this task.

### 1. Pin Module Versions

Use version constraints for registry modules.

```hcl
version = "~> 5.0"
```

This helps avoid unexpected changes.

### 2. Keep Modules Focused

Each module should have a clear purpose, e.g. `ec2-instance`, `security-group`. A module should not contain unrelated infrastructure.

### 3. Use Variables

Avoid hardcoding values inside reusable modules. Instead of hardcoding an instance type, use:

```hcl
var.instance_type
```

### 4. Use Outputs

Outputs allow other modules or the root configuration to consume important values, e.g.:

```hcl
module.web_sg.sg_id
```

### 5. Document Modules

Each reusable module should ideally have its own README explaining:

- Purpose
- Variables
- Outputs
- Usage
- Example configuration

---

## What I Learned

Day 65 helped me understand how Terraform can move from a large collection of resources toward a more structured and reusable infrastructure design.

The main concepts I practiced were:

- Terraform root modules
- Terraform child modules
- Custom EC2 modules
- Custom Security Group modules
- Module variables
- Module outputs
- Module-to-module dependencies
- Dynamic blocks
- Terraform Registry modules
- Module version constraints
- Terraform state migration
- Terraform state imports
- Module resource addresses
- `terraform init -upgrade`
- Reusable infrastructure design

The biggest practical lesson was that **modules allow the same infrastructure pattern to be reused without duplicating the resource configuration**.

For example, instead of writing two separate EC2 resources, I created one EC2 module and called it twice:

```text
EC2 Module
   |
   +── terraweek-web
   |
   └── terraweek-api
```

---

## Day 65 Key Takeaway

Terraform modules are similar to reusable functions in programming. Instead of repeatedly writing the same infrastructure code, I can create a module once and provide different inputs whenever I need another instance of that infrastructure.

The final architecture changed from:

```text
Large main.tf
      |
      +── VPC
      +── Subnet
      +── Security Group
      +── EC2
      +── EC2
```

to:

```text
Root Module
    |
    +── VPC Registry Module
    |
    +── Security Group Module
    |
    +── EC2 Module
    |
    └── EC2 Module
```

This makes Terraform infrastructure more:

- Reusable
- Maintainable
- Scalable
- Organized
- Consistent

---

## Commands Practiced

```bash
terraform init
terraform plan
terraform apply
terraform state list
terraform state mv
terraform state rm
terraform import
terraform providers
terraform init -upgrade
terraform destroy
```

---

## Verification

The final Terraform verification returned:

```text
No changes. Your infrastructure matches the configuration.
```

This confirmed that Terraform's state and the actual AWS infrastructure were synchronized with the module-based configuration.

---

## Day 65 Completion

**Day 65 — Terraform Modules: Build Reusable Infrastructure**

Completed:

- [x] Custom EC2 module
- [x] Custom Security Group module
- [x] Reused EC2 module for multiple servers
- [x] Official Terraform VPC Registry module
- [x] Module-to-module wiring
- [x] Terraform state migration
- [x] Existing route import
- [x] Module versioning
- [x] Terraform state verification
- [x] Infrastructure reconciliation

**Day 65 completed successfully.**