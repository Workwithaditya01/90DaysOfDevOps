# Day 65 — Terraform Modules: Build Reusable Infrastructure

## 📌 Overview

Day 65 of my **#90DaysOfDevOps** journey focused on understanding and implementing **Terraform Modules**.

The main goal was to move from a single large Terraform configuration toward a **modular, reusable, and maintainable infrastructure design**.

In this task, I created custom Terraform modules for **EC2 instances** and **Security Groups**, and also used the official **Terraform AWS VPC Registry Module** to provision networking infrastructure.

---

## 🎯 Objectives

- Understand Terraform root and child modules
- Create a reusable EC2 module
- Create a reusable Security Group module
- Pass variables between modules
- Use module outputs as inputs for other modules
- Reuse the same EC2 module for multiple servers
- Use an official Terraform Registry module
- Manage module versions
- Migrate existing Terraform state into module resources
- Import an existing AWS route into Terraform state
- Verify infrastructure using Terraform plan and state commands

---

## 🏗️ Project Structure

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

---

## 🧩 Modules Used

### 1. Custom EC2 Module

Location: `modules/ec2-instance/`

The EC2 module accepts:

- AMI ID
- Instance type
- Subnet ID
- Security Group IDs
- Instance name
- Tags

The same module was reused to create:

```text
terraweek-web
terraweek-api
```

Both instances use:

```text
Instance Type: t3.micro
Region: ap-south-1
```

---

### 2. Custom Security Group Module

Location: `modules/security-group/`

The module accepts a list of ingress ports and dynamically creates the required rules.

Ports used:

```text
22  → SSH
80  → HTTP
443 → HTTPS
```

The module uses a Terraform `dynamic` block to generate the ingress rules.

---

### 3. Terraform Registry VPC Module

The project uses the official VPC module:

```text
terraform-aws-modules/vpc/aws
```

Version constraint:

```hcl
version = "~> 5.0"
```

The VPC configuration includes:

- VPC CIDR: `10.0.0.0/16`
- 2 Availability Zones
- 2 Public Subnets
- 2 Private Subnets
- Internet Gateway
- Public Route Table
- Private Route Tables
- DNS Hostnames
- Public IP assignment

---

## 🔗 Module Architecture

```text
                    Root Module
                        │
                        ├──────────────────────┐
                        │                      │
                        ▼                      ▼
                 VPC Registry             Security
                    Module                 Group Module
                        │                      │
                        │                      │
                        └──────────┬───────────┘
                                   │
                                   ▼
                              EC2 Module
                              /        \
                             /          \
                            ▼            ▼
                     Web Server      API Server
                     t3.micro        t3.micro
```

The important concept demonstrated here is **module reusability**.

Instead of creating separate EC2 resource definitions for every server, one EC2 module can be called multiple times with different values.

---

## 🔗 Module-to-Module Communication

The VPC module provides the VPC ID:

```hcl
module.vpc.vpc_id
```

The Security Group module uses that VPC ID:

```hcl
vpc_id = module.vpc.vpc_id
```

The Security Group module provides its ID:

```hcl
module.web_sg.sg_id
```

The EC2 modules use that Security Group:

```hcl
security_group_ids = [module.web_sg.sg_id]
```

The VPC module also provides the public subnet:

```hcl
module.vpc.public_subnets[0]
```

which is passed to the EC2 module.

This creates a dependency chain between the modules.

---

## 🔄 Terraform State Migration

The infrastructure initially existed using manually written Terraform resources.

When the VPC was replaced with the Registry module, the existing resources were moved to the new module addresses instead of recreating them.

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

The old availability-zone data source was removed from the state:

```bash
terraform state rm 'data.aws_availability_zones.available'
```

---

## 📥 Importing an Existing Route

During the migration, Terraform detected that a public route already existed in AWS.

Instead of creating a duplicate route, the existing route was imported:

```bash
terraform import 'module.vpc.aws_route.public_internet_gateway[0]' 'rtb-077659a85fd88f5be_0.0.0.0/0'
```

After importing the resource, Terraform successfully reconciled the state with the actual AWS infrastructure.

---

## ✅ Verification

The final configuration was verified using:

```bash
terraform plan
```

Final result:

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

This confirmed that the Terraform configuration, state, and AWS infrastructure were synchronized.

---

## 🔍 Terraform State

The infrastructure was also verified using:

```bash
terraform state list
```

Module resources appeared with module prefixes such as:

```text
module.vpc.aws_vpc.this[0]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_internet_gateway.this[0]
module.web_sg.aws_security_group.this
module.web_server.aws_instance.this
module.api_server.aws_instance.this
```

This demonstrates how Terraform tracks resources managed through modules.

---

## 🔢 Module Versioning

Terraform module versions can be controlled using version constraints.

**Exact Version**

```hcl
version = "5.1.0"
```

**Compatible 5.x Version**

```hcl
version = "~> 5.0"
```

**Explicit Version Range**

```hcl
version = ">= 5.0, < 6.0"
```

The project uses:

```hcl
version = "~> 5.0"
```

---

## 🛠️ Commands Practiced

```bash
terraform init
terraform init -upgrade
terraform plan
terraform apply
terraform state list
terraform state mv
terraform state rm
terraform import
terraform providers
terraform version
terraform destroy
```

---

## 📚 Key Learnings

Through this task, I learned how Terraform modules help create reusable infrastructure components.

**Before Modules**

```text
Large main.tf
│
├── VPC
├── Subnet
├── Security Group
├── EC2
└── EC2
```

**After Modules**

```text
Root Module
│
├── VPC Registry Module
├── Security Group Module
├── EC2 Module
└── EC2 Module
```

The biggest takeaway is that **infrastructure code can be designed like reusable building blocks**.

A module can be created once and reused multiple times with different inputs.

---

## ⭐ Best Practices Followed

1. Pin Terraform module versions
2. Keep modules focused on a specific purpose
3. Use variables instead of hardcoding reusable values
4. Expose important values through outputs
5. Document reusable modules

---

## 🌐 AWS Infrastructure

```text
AWS
│
└── VPC: terraweek-vpc
    │
    ├── Public Subnet 1
    │   ├── terraweek-web
    │   └── terraweek-api
    │
    ├── Public Subnet 2
    │
    ├── Private Subnet 1
    │
    ├── Private Subnet 2
    │
    ├── Internet Gateway
    │
    ├── Route Tables
    │
    └── Security Group
        ├── SSH - 22
        ├── HTTP - 80
        └── HTTPS - 443
```

---

## 🚀 Final Result

Day 65 was successfully completed.

I moved from manually defined Terraform infrastructure to a **modular architecture using custom and public Registry modules**.

The project successfully demonstrates:

- Reusable Terraform modules
- Custom infrastructure components
- Official Registry modules
- Module dependencies
- State migration
- Resource import
- Module versioning
- Infrastructure verification

---

## #90DaysOfDevOps

**Day 65 — Terraform Modules: Build Reusable Infrastructure**

> Build once. Reuse everywhere. Automate consistently.

`#Terraform` `#AWS` `#DevOps` `#InfrastructureAsCode` `#IaC` `#Cloud` `#90DaysOfDevOps`
