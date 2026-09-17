# Day 67 — TerraWeek Capstone: Multi-Environment Infrastructure with Workspaces and Modules

Seven days of Terraform culminate here: one codebase, three isolated AWS environments
(dev, staging, prod), driven by custom modules and Terraform workspaces.

---

## 1. Project Structure

```
terraweek-capstone/
├── main.tf                   # Root module -- calls child modules
├── variables.tf               # Root variables (with validation blocks)
├── outputs.tf                 # Root outputs
├── providers.tf                # AWS provider + backend config
├── locals.tf                   # Local values driven by terraform.workspace
├── dev.tfvars                  # Dev environment values
├── staging.tfvars              # Staging environment values
├── prod.tfvars                 # Prod environment values
├── .gitignore                  # Ignores state, .terraform/, tfvars
└── modules/
    ├── vpc/
    │   ├── main.tf              # VPC, subnet, IGW, route table, association
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-group/
    │   ├── main.tf              # SG with dynamic ingress rules
    │   ├── variables.tf
    │   └── outputs.tf
    └── ec2-instance/
        ├── main.tf              # EC2 instance with tags
        ├── variables.tf
        └── outputs.tf
```

### Why is this file structure best practice?

- **Separation of concerns.** Anyone opening this repo instantly knows where to look:
  provider/backend config lives in `providers.tf`, variable declarations in
  `variables.tf`, computed values in `locals.tf`. Nothing is buried inside a giant
  `main.tf`.
- **Modules are reusable and independently testable.** Each module under `modules/`
  does exactly one thing (networking, firewall rules, compute) and can be
  `terraform validate`-ed, versioned, and reused in a completely different root
  module or project without modification.
- **Environment differences live in data, not code.** The `.tfvars` files are the
  only place dev/staging/prod actually diverge. The `.tf` logic itself never
  branches on environment name with `if` statements — it just consumes whatever
  `terraform.workspace` and the loaded tfvars resolve to. This is what makes "one
  codebase, three environments" actually true instead of aspirational.
- **`.gitignore` protects secrets and prevents state corruption.** State files
  contain resource IDs and sometimes sensitive attributes (e.g. passwords in
  plaintext if a resource exposes them); tfvars can contain account-specific or
  sensitive values. None of that belongs in git history.
- **Predictable onboarding.** A new engineer who has seen one Terraform repo built
  this way can navigate any other repo built the same way. That consistency is
  the entire point of "infrastructure as code" — the structure itself becomes
  part of the documentation.

---

## 2. Terraform Workspaces — Concepts

| Question | Answer |
|---|---|
| What does `terraform.workspace` return? | The name of the currently selected workspace as a string (`"default"`, `"dev"`, `"staging"`, `"prod"`). |
| Where is each workspace's state stored? | Local backend: `terraform.tfstate.d/<workspace>/terraform.tfstate`. `default` uses the root `terraform.tfstate` directly. Remote S3 backend: key is auto-namespaced as `env:/<workspace>/<key>`. |
| Workspaces vs. separate directories per environment | Workspaces = one codebase, many state files, switched via CLI — minimal duplication, but only one `.tfvars` load away from applying against the wrong environment. Separate directories = fully independent code, backends, and access controls per environment — more duplication, but a much smaller blast radius, since there's no shared command context to mix up. Workspaces suit environments that are structurally identical (this capstone); separate directories suit environments that need independent module versions, review gates, or strict prod access boundaries. |

---

## 3. Custom Modules

### Module 1: `modules/vpc`

**variables.tf**
```hcl
variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone to place the public subnet in"
  type        = string
}
```

**main.tf**
```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

**outputs.tf**
```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}
```

### Module 2: `modules/security-group`

**variables.tf**
```hcl
variable "vpc_id" {
  type = string
}

variable "ingress_ports" {
  type = list(number)
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}
```

**main.tf**
```hcl
resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} ${var.environment}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow inbound on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
```

**outputs.tf**
```hcl
output "sg_id" {
  value = aws_security_group.this.id
}
```

### Module 3: `modules/ec2-instance`

**variables.tf**
```hcl
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}
```

**main.tf**
```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-server"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
```

**outputs.tf**
```hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
```

---

## 4. Root Module — Workspace-Aware Wiring

**locals.tf**
```hcl
locals {
  environment = terraform.workspace
  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Workspace   = terraform.workspace
  }
}
```

**main.tf**
```hcl
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

module "vpc" {
  source = "./modules/vpc"

  cidr               = var.vpc_cidr
  public_subnet_cidr = var.subnet_cidr
  environment        = local.environment
  project_name       = var.project_name
  availability_zone  = data.aws_availability_zones.available.names[0]
}

module "security_group" {
  source = "./modules/security-group"

  vpc_id        = module.vpc.vpc_id
  ingress_ports = var.ingress_ports
  environment   = local.environment
  project_name  = var.project_name
}

module "ec2_instance" {
  source = "./modules/ec2-instance"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security_group.sg_id]
  environment        = local.environment
  project_name       = var.project_name
}
```

The AMI and availability zone are resolved with **data sources** rather than
hardcoded — a direct callback to Day 63. This means the tfvars files only need
to declare what genuinely differs between environments.

---

## 5. Environment tfvars — the differences that matter

| Variable | dev.tfvars | staging.tfvars | prod.tfvars |
|---|---|---|---|
| `vpc_cidr` | `10.0.0.0/16` | `10.1.0.0/16` | `10.2.0.0/16` |
| `subnet_cidr` | `10.0.1.0/24` | `10.1.1.0/24` | `10.2.1.0/24` |
| `instance_type` | `t2.micro` | `t2.small` | `t3.small` |
| `ingress_ports` | `[22, 80]` | `[22, 80, 443]` | `[80, 443]` |

**Key differences highlighted:**
- **Non-overlapping CIDR ranges** — each environment gets its own `/16`, so there's
  no risk of accidental VPC peering conflicts if these networks are ever connected.
- **SSH (22) is open in dev and staging but closed in prod.** Production access
  should go through a bastion, SSM Session Manager, or a VPN — never a public port
  22 straight into the instance.
- **Instance sizing scales up per environment**: `t2.micro` → `t2.small` →
  `t3.small`, mirroring how real teams give prod (and to a lesser extent staging)
  more headroom than dev.

---

## 6. Deployment & Verification

```bash
terraform init
terraform validate
terraform fmt -recursive

terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

terraform workspace select dev
terraform apply -var-file="dev.tfvars"

terraform workspace select staging
terraform apply -var-file="staging.tfvars"

terraform workspace select prod
terraform apply -var-file="prod.tfvars"

# Verify each workspace independently
terraform workspace select dev     && terraform output
terraform workspace select staging && terraform output
terraform workspace select prod    && terraform output
```

**AWS console verification checklist:**
- [ ] Three separate VPCs, with CIDR ranges `10.0.0.0/16`, `10.1.0.0/16`, `10.2.0.0/16`
- [ ] Three EC2 instances of types `t2.micro`, `t2.small`, `t3.small`
- [ ] `Name` tags: `terraweek-dev-server`, `terraweek-staging-server`, `terraweek-prod-server`
- [ ] Dev/staging security groups allow port 22; prod does not

*(Insert screenshots here: all three environments running simultaneously in the
AWS console, and the `terraform output` results from each workspace.)*

**Isolation verdict:** Yes — all three environments are completely isolated.
Each has its own VPC (non-overlapping CIDR), its own subnet, its own security
group, and its own EC2 instance. There is no shared networking, no shared
security group, and no shared state — each workspace's state file only knows
about its own resources. The only thing shared is the `.tf` code itself.

---

## 7. Terraform Best Practices Guide (Days 61–67 distilled)

1. **File structure** — separate files for providers, variables, outputs, main,
   and locals. No monolithic `main.tf` holding everything.
2. **State management** — always use a remote backend (S3 + DynamoDB, Terraform
   Cloud, etc.) in real projects; enable state locking to prevent concurrent
   writes; enable versioning on the state bucket so a bad apply can be rolled
   back.
3. **Variables** — never hardcode values that differ by environment; use one
   `.tfvars` file per environment; add `validation` blocks to catch bad input
   (e.g. malformed CIDRs) before `apply` ever touches the cloud.
4. **Modules** — one concern per module (networking, security, compute, etc.);
   always define explicit inputs and outputs so the module's contract is clear;
   pin exact or constrained versions for any module pulled from the public
   registry.
5. **Workspaces** — use them for lightweight environment isolation when the
   environments are structurally identical; reference `terraform.workspace` in
   locals/tags rather than duplicating logic per environment; remember they
   share the same backend config and code, so mistakes in the wrong workspace
   are still possible — always `terraform workspace show` before applying.
6. **Security** — `.gitignore` state files and tfvars containing secrets;
   encrypt state at rest (SSE on the S3 bucket, or the backend's built-in
   encryption); restrict who/what can read or write the backend, since state can
   contain sensitive resource attributes.
7. **Commands** — always run `terraform plan` before `apply` and read the diff;
   run `terraform fmt` and `terraform validate` before every commit so style and
   syntax issues never reach code review.
8. **Tagging** — tag every resource with at minimum `Project`, `Environment`,
   and `ManagedBy`, so cost allocation and ownership are traceable in the AWS
   console without opening Terraform at all.
9. **Naming** — a consistent `<project>-<environment>-<resource>` prefix pattern
   makes every resource identifiable at a glance, in the console or in `plan`
   output.
10. **Cleanup** — `terraform destroy` non-production environments when they're
    not actively in use; idle dev/staging infrastructure is pure cost with no
    offsetting value.

---

## 8. TerraWeek Progress Map

| Day | Concepts |
|---|---|
| 61 | IaC, HCL, `init`/`plan`/`apply`/`destroy`, state basics |
| 62 | Providers, resources, dependencies, lifecycle |
| 63 | Variables, outputs, data sources, locals, functions |
| 64 | Remote backend, locking, import, drift |
| 65 | Custom modules, registry modules, versioning |
| 66 | EKS with modules, real-world provisioning |
| 67 | Workspaces, multi-env, capstone project |

---

## 9. Cleanup

```bash
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"

terraform workspace select staging
terraform destroy -var-file="staging.tfvars"

terraform workspace select dev
terraform destroy -var-file="dev.tfvars"

terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod
```

Verified in the AWS console: no VPCs, instances, security groups, or internet
gateways remain from any of the three environments. AWS account is clean.

---

## Learn in Public

> Completed the TerraWeek Challenge — seven days from `terraform init` to a full
> multi-environment infrastructure project. Custom modules for VPC, security
> groups, and EC2. Three environments deployed with workspaces. One codebase,
> three isolated environments, zero console clicks.
>
> #90DaysOfDevOps #TerraWeek #DevOpsKaJosh #TrainWithShubham