# TerraWeek Capstone — Multi-Environment AWS Infrastructure

A single Terraform codebase that deploys three fully isolated AWS environments —
**dev**, **staging**, and **prod** — using custom modules and Terraform
workspaces. Built as the capstone for the seven-day TerraWeek challenge
(#90DaysOfDevOps).

Full write-up, module source, and best-practices notes: see
[`day-67-terraweek-capstone.md`](./day-67-terraweek-capstone.md).

---

## What this deploys, per environment

| Resource | Description |
|---|---|
| VPC | Dedicated `/16` CIDR block, no overlap between environments |
| Public subnet | With route to an Internet Gateway |
| Security group | Dynamic ingress rules (ports vary per environment) |
| EC2 instance | Amazon Linux 2, instance type scales per environment |

| | dev | staging | prod |
|---|---|---|---|
| VPC CIDR | `10.0.0.0/16` | `10.1.0.0/16` | `10.2.0.0/16` |
| Subnet CIDR | `10.0.1.0/24` | `10.1.1.0/24` | `10.2.1.0/24` |
| Instance type | `t2.micro` | `t2.small` | `t3.small` |
| Open ports | `22, 80` | `22, 80, 443` | `80, 443` (no SSH) |

---

## Project structure

```
terraweek-capstone/
├── main.tf                 # Root module — calls the three child modules
├── variables.tf             # Root variables (with validation blocks)
├── outputs.tf                # Root outputs
├── providers.tf               # AWS provider + backend config
├── locals.tf                   # Workspace-driven locals (terraform.workspace)
├── dev.tfvars
├── staging.tfvars
├── prod.tfvars
├── .gitignore
└── modules/
    ├── vpc/                    # VPC, subnet, IGW, route table
    ├── security-group/          # SG with dynamic ingress rules
    └── ec2-instance/              # EC2 instance with tags
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- An AWS account with credentials configured (`aws configure`, or the standard
  `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`
  environment variables)
- Sufficient IAM permissions to create VPCs, subnets, internet gateways, route
  tables, security groups, and EC2 instances

---

## Usage

### 1. Initialize

```bash
cd terraweek-capstone
terraform init
terraform validate
terraform fmt -recursive
```

### 2. Create the workspaces

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

### 3. Deploy an environment

Select the workspace, then plan and apply with the matching `.tfvars` file.
**Always pass `-var-file` explicitly** — it does not get auto-loaded.

```bash
terraform workspace select dev
terraform plan  -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

Repeat with `staging.tfvars` / `terraform workspace select staging`, and
`prod.tfvars` / `terraform workspace select prod`.

### 4. Verify

```bash
terraform workspace select dev     && terraform output
terraform workspace select staging && terraform output
terraform workspace select prod    && terraform output
```

Each workspace should return distinct `vpc_id`, `subnet_id`,
`security_group_id`, `instance_id`, and `instance_public_ip` values — confirming
the three environments are fully isolated from one another.

### 5. Tear down

Destroy in reverse order, always with the matching `-var-file`:

```bash
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"

terraform workspace select staging
terraform destroy -var-file="staging.tfvars"

terraform workspace select dev
terraform destroy -var-file="dev.tfvars"
```

Then remove the workspaces (you must switch off a workspace before deleting it):

```bash
terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod
```

---

## Notes

- The AMI (latest Amazon Linux 2) and availability zone are resolved
  automatically via `data` sources — you never need to hardcode them in tfvars.
- State is local by default (`terraform.tfstate.d/<workspace>/terraform.tfstate`).
  `providers.tf` includes a commented example for switching to an S3 + DynamoDB
  remote backend, which is what you'd want in a real production setup.
- `.gitignore` excludes `.terraform/`, all `.tfstate*` files, `.terraform.lock.hcl`,
  and all `*.tfvars` files, since state and tfvars can carry sensitive or
  account-specific values. The tfvars content is documented in
  `day-67-terraweek-capstone.md` for reference instead.
- Workspaces work well here because all three environments are *structurally
  identical* — only variable values differ. For environments that need
  independent module versions or stricter access boundaries (e.g. prod), a
  separate-directory-per-environment layout is often the safer real-world choice.

---

## License

Personal learning project — part of the
[#90DaysOfDevOps](https://github.com/LondheShubham153/90DaysOfDevOps) /
TrainWithShubham TerraWeek challenge.