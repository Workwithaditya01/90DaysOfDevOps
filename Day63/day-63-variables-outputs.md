# Day 63 — Terraform Variables, Outputs, Data Sources & Expressions

## 📌 Overview

Day 63 of my `#90DaysOfDevOps` journey focused on making Terraform configurations more **dynamic, reusable, and environment-friendly**.

On Day 62, I created an AWS networking infrastructure using Terraform. Most of the configuration contained hardcoded values.

Today, I converted that configuration into a more reusable Terraform setup by working with:

- Terraform Variables
- Variable Types
- `.tfvars` Files
- Variable Precedence
- Terraform Outputs
- Data Sources
- Local Values
- Terraform Functions
- Expressions
- Conditional Expressions
- Dynamic Security Group Rules

---

## 🎯 Today's Objectives

By the end of Day 63, I practiced:

1. Creating and using Terraform variables
2. Using different Terraform variable types
3. Managing environment-specific values with `.tfvars`
4. Creating Terraform outputs
5. Dynamically retrieving AWS AMIs
6. Dynamically retrieving Availability Zones
7. Creating reusable local values
8. Applying common tags using `merge()`
9. Using Terraform built-in functions
10. Using conditional expressions
11. Understanding how Terraform calculates infrastructure dynamically

---

## 🏗️ Infrastructure

The Terraform configuration creates the following AWS infrastructure:

```
                    AWS
                     │
                     ▼
                  VPC
             10.0.0.0/16
                     │
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
    Public Subnet          Internet Gateway
    10.0.1.0/24
          │
          ▼
     Route Table
          │
          ▼
   Security Group
   22 / 80 / 443
          │
          ▼
      EC2 Instance
```

---

## 📁 Project Structure

```
day63/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── data.tf
├── locals.tf
├── terraform.tfvars
├── prod.tfvars
└── day-63-variables-outputs.md
```

---

## 1️⃣ Terraform Variables

Variables allow us to remove hardcoded values from Terraform configurations.

Instead of writing:

```hcl
region = "ap-south-1"
```

we can use:

```hcl
region = var.region
```

This makes the configuration reusable.

### `variables.tf`

```hcl
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "allowed_ports" {
  description = "Ports allowed through the security group"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "extra_tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
```

### 🔤 Terraform Variable Types

Terraform supports different variable types.

| Type     | Example                   |
|----------|----------------------------|
| `string` | `"dev"`                   |
| `number` | `2`                       |
| `bool`   | `true`                    |
| `list`   | `["dev", "prod"]`         |
| `map`    | `{ Environment = "dev" }` |

For this project, I used:

- `string`
- `list(number)`
- `map(string)`

---

## 2️⃣ Terraform `.tfvars` Files

`.tfvars` files allow us to provide values for Terraform variables without modifying the main configuration.

### `terraform.tfvars`

```hcl
project_name  = "terraweek"
environment   = "dev"
instance_type = "t2.micro"
```

Terraform automatically loads `terraform.tfvars`.

### `prod.tfvars`

```hcl
project_name  = "terraweek"
environment   = "prod"
instance_type = "t3.small"
vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"
```

This allows the same Terraform configuration to be used for different environments.

**Using production variables:**

```bash
terraform plan -var-file="prod.tfvars"
```

**CLI variable override:**

```bash
terraform plan -var="instance_type=t2.nano"
```

---

## 3️⃣ Terraform Variable Precedence

Terraform can receive variable values from multiple locations.

The general order practiced today was:

```
Default Values
      ↓
terraform.tfvars
      ↓
*.auto.tfvars
      ↓
-var-file
      ↓
-var
      ↓
TF_VAR_* Environment Variables
```

Example:

```bash
export TF_VAR_environment="staging"
```

Terraform can then use the environment variable as the value of `var.environment`.

---

## 4️⃣ Terraform Outputs

Outputs allow Terraform to display useful information after creating infrastructure.

### `outputs.tf`

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "instance_id" {
  value = aws_instance.server.id
}

output "instance_public_ip" {
  value = aws_instance.server.public_ip
}

output "instance_public_dns" {
  value = aws_instance.server.public_dns
}

output "security_group_id" {
  value = aws_security_group.main.id
}
```

### Applying Terraform

```bash
terraform apply
```

Terraform displayed outputs similar to:

```
instance_id         = "i-0cdd93e0aed3f2bf8"
instance_public_ip  = "13.127.134.98"
security_group_id   = "sg-0a583f93bdb9c19d9"
subnet_id           = "subnet-00dd5923929511f55"
vpc_id              = "vpc-04a079aeb390a0253"
```

### Getting a Specific Output

```bash
terraform output instance_public_ip
```

Example:

```
"13.127.134.98"
```

Outputs are useful for quickly retrieving:

- Instance IDs
- Public IP addresses
- VPC IDs
- Subnet IDs
- Security Group IDs
- DNS names

---

## 5️⃣ Terraform Data Sources

A **resource** creates or manages infrastructure.
A **data source** reads information that already exists.

```
Resource
   ↓
Creates / Manages

Data Source
   ↓
Reads / Looks Up
```

### AWS AMI Data Source

Instead of hardcoding an AMI ID, I used a data source.

### `data.tf`

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
```

The EC2 resource can then use:

```hcl
ami = data.aws_ami.amazon_linux.id
```

instead of a hardcoded AMI ID.

---

## 6️⃣ Dynamic Availability Zone

The Availability Zone is retrieved dynamically:

```hcl
availability_zone = data.aws_availability_zones.available.names[0]
```

Terraform successfully retrieved the available Availability Zones in `ap-south-1`.

The AMI data source also successfully returned:

```
ami-001910b11845a22c7
```

This makes the configuration less dependent on manually entered AWS values.

---

## 7️⃣ Terraform Locals

Locals allow us to define reusable values inside Terraform.

### `locals.tf`

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

If:

```hcl
project_name = "terraweek"
environment  = "dev"
```

Then `local.name_prefix` becomes:

```
terraweek-dev
```

---

## 8️⃣ Common Tags with `merge()`

Instead of repeating tags for every resource, common tags can be reused.

Example:

```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-server"
})
```

The resulting tags are:

```
Project     = terraweek
Environment = dev
ManagedBy   = Terraform
Name        = terraweek-dev-server
```

This makes resource tagging cleaner and easier to maintain.

---

## 9️⃣ Extra Tags

The `extra_tags` variable allows additional tags to be passed into the configuration.

Example:

```hcl
extra_tags = {
  Owner = "DevOps"
  Team  = "Cloud"
}
```

These can be merged with the common tags:

```hcl
tags = merge(local.common_tags, var.extra_tags, {
  Name = "${local.name_prefix}-server"
})
```

This provides a flexible tagging system.

---

## 🔟 Terraform Functions

Terraform provides built-in functions for manipulating strings, lists, maps, numbers, CIDR blocks and other values.

I practiced several functions using:

```bash
terraform console
```

### `upper()`

```hcl
upper("terraform")
```

Output: `"TERRAFORM"` — converts text to uppercase.

### `join()`

```hcl
join("-", ["terraweek", "dev", "server"])
```

Output: `"terraweek-dev-server"` — combines multiple strings using a separator.

### `length()`

```hcl
length(var.allowed_ports)
```

Output: `3` — the list contains `22`, `80`, `443`.

### `lookup()`

```hcl
lookup({ dev = "t2.micro", prod = "t3.small" }, "prod", "t2.micro")
```

Output: `"t3.small"` — retrieves a value from a map.

### `cidrsubnet()`

```hcl
cidrsubnet(var.vpc_cidr, 8, 1)
```

Output: `"10.0.1.0/24"` — calculates subnet CIDR ranges from a larger network.

```
VPC
10.0.0.0/16
      │
      ▼
Subnet
10.0.1.0/24
```

---

## 1️⃣1️⃣ Conditional Expressions

Terraform supports conditional expressions.

The syntax is:

```hcl
condition ? value_if_true : value_if_false
```

Example:

```hcl
var.environment == "prod" ? "t3.small" : "t2.micro"
```

For the current environment (`environment = dev`), Terraform returns `"t2.micro"`.

For production (`environment = prod`), Terraform would return `"t3.small"`.

This is useful when infrastructure requirements change between environments.

---

## 🧪 Terraform Console Practice

I tested the functions using:

```bash
terraform console
```

The commands and outputs were:

```
> upper("terraform")
"TERRAFORM"

> join("-", ["terraweek", "dev", "server"])
"terraweek-dev-server"

> length(var.allowed_ports)
3

> lookup({dev="t2.micro", prod="t3.small"}, "prod", "t2.micro")
"t3.small"

> cidrsubnet(var.vpc_cidr, 8, 1)
"10.0.1.0/24"

> var.environment == "prod" ? "t3.small" : "t2.micro"
"t2.micro"
```

---

## 🔍 Terraform Validation

After modifying the configuration, I used:

```bash
terraform fmt
```

to format the Terraform files. Then:

```bash
terraform validate
```

to verify that the configuration was syntactically valid. Finally:

```bash
terraform plan
```

to see what Terraform planned to change.

---

## ⚠️ Terraform Plan — EC2 Replacement

After replacing the hardcoded AMI with the dynamic AMI data source, Terraform detected that the current EC2 instance used a different AMI.

The plan showed:

```
ami-01a00762f46d584a1
        ↓
ami-001910b11845a22c7
```

Changing an EC2 AMI forces the instance to be replaced. Terraform therefore planned:

```
-/+ destroy and then create replacement
```

The plan also showed the public IP configuration changing. The resulting plan was:

```
Plan: 1 to add, 4 to change, 1 to destroy.
```

The replacement was related to the EC2 instance and did not mean the entire VPC infrastructure would be destroyed.

---

## 🧠 Key Learnings

**Variables** — remove hardcoded values and make Terraform configurations reusable.

**`.tfvars`** — make it easy to provide different values for different environments.

**Outputs** — allow important infrastructure information to be displayed after deployment.

**Data Sources** — allow Terraform to retrieve existing information from AWS instead of manually hardcoding values.

**Locals** — allow frequently used expressions and values to be defined once and reused.

**Functions** — help manipulate strings, lists, maps and network values.

**Conditionals** — allow Terraform configurations to behave differently depending on the environment or another condition.

---

## 📊 Resource vs Data Source vs Variable vs Local vs Output

| Terraform Concept | Purpose                            |
|--------------------|-------------------------------------|
| Variable           | Accepts input values                |
| Resource           | Creates/manages infrastructure      |
| Data Source        | Reads existing information          |
| Local              | Stores reusable calculated values   |
| Output             | Displays useful information         |

A simple way to remember:

```
Variable      → Input
Data Source   → Lookup
Local         → Calculate / Reuse
Resource      → Create / Manage
Output        → Show Result
```

---

## 🛠️ Commands Practiced

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform output instance_public_ip
terraform plan -var-file="prod.tfvars"
terraform plan -var="instance_type=t2.nano"
terraform console
```

---

## 🎯 Day 63 Outcome

Today I transformed my Terraform configuration from a mostly hardcoded setup into a more **dynamic and reusable Infrastructure as Code configuration**.

The major improvements were:

```
Hardcoded Configuration
        ↓
Terraform Variables
        ↓
Environment-specific .tfvars
        ↓
Terraform Outputs
        ↓
Dynamic AWS Data Sources
        ↓
Reusable Locals
        ↓
Terraform Functions
        ↓
Conditional Expressions
        ↓
More Reusable Infrastructure
```

---

## 🚀 Next Step

The next stage of the Terraform journey will focus on building more advanced and production-oriented infrastructure patterns. The goal is to continue moving from simple Terraform configurations toward **modular, reusable and scalable Infrastructure as Code**.

---

## #90DaysOfDevOps

**Day 63 completed ✅**

| | |
|---|---|
| **Topics** | Terraform Variables, Outputs, Data Sources, Locals, Functions, Expressions & Conditionals |
| **Cloud** | AWS |
| **IaC Tool** | Terraform |
| **Region** | `ap-south-1` |
| **Environment** | `dev` |
