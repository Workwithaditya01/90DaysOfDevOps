# Day 62 — Providers, Resources and Dependencies

Building a complete, connected AWS networking stack with Terraform, and understanding how Terraform decides the order in which resources get created.

---

## Task 1: Explore the AWS Provider

**Project structure**

```
terraform-aws-infra/
├── providers.tf
├── main.tf
```

**`providers.tf`**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
```
**Running `terraform init`**

```
terraform init
```

Output shows something like:

```
Installing hashicorp/aws v5.60.0...
Terraform has been successfully initialized!
```

Terraform picks the **latest version that satisfies `~> 5.0`** available at the time of `init` — in this case `5.60.0`.

**Reading `.terraform.lock.hcl`**

This file records the *exact* provider version and package checksums that were installed. Its job is to make builds **reproducible** — if you or a teammate runs `terraform init` again next month, you get the same provider version instead of whatever the newest 5.x happens to be at that moment. It should be committed to version control.

**`~> 5.0` vs `>= 5.0` vs `= 5.0.0`**

| Constraint | Meaning |
|---|---|
| `~> 5.0` | "Pessimistic constraint" — allow any version from `5.0.0` up to (but not including) `6.0.0`. Lets you get patch and minor upgrades automatically, but blocks breaking major version jumps. This is the safest default for most projects. |
| `>= 5.0` | Allow `5.0` or **anything newer**, including `6.0`, `7.0`, etc. Riskiest option — a future major version with breaking changes could silently get installed. |
| `= 5.0.0` | Locks to **exactly** `5.0.0`. No upgrades at all, even bug fixes, until you manually bump the version. Safest for reproducibility, but you miss security patches unless you update by hand. |

`~> 5.0` is the sweet spot: room to breathe for minor updates, protection against breaking major-version changes.

---

## Task 2: Build a VPC from Scratch

**`main.tf`**

```hcl
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
```

**`terraform plan`**

```
Plan: 5 to add, 0 to change, 0 to destroy.
```

**Verify:** After `terraform apply`, the AWS VPC console shows the VPC, its subnet, the attached internet gateway, and the route table with the subnet listed under "Explicit subnet associations."

![VPC](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/303af58ca7ae3d1cc43341dffd8da37e11a2a5a9/Images/Day%2062/2.png)
---

## Task 3: Understand Implicit Dependencies

**How does Terraform know to create the VPC before the subnet?**

Terraform doesn't run resources in the order they're written in the file. Instead, it parses every resource block for references to other resources (like `aws_vpc.main.id`). Every such reference becomes a **node and edge** in an internal dependency graph. Terraform then does a topological sort of that graph and walks it — creating a resource only after everything it depends on already exists.

**What would happen if you tried to create the subnet before the VPC existed?**

It would fail — `aws_subnet` requires a real `vpc_id`, and there's no VPC to reference. In practice this can't actually happen when Terraform manages both resources, because the dependency graph guarantees the VPC is created first. It could only happen if you manually tried to create the subnet via a hardcoded (wrong) VPC ID, which would fail at the AWS API level with something like `InvalidVpcID.NotFound`.

**All implicit dependencies found in this config:**

| Resource | Depends on | Via |
|---|---|---|
| `aws_subnet.public` | `aws_vpc.main` | `vpc_id = aws_vpc.main.id` |
| `aws_internet_gateway.main` | `aws_vpc.main` | `vpc_id = aws_vpc.main.id` |
| `aws_route_table.public` | `aws_vpc.main` | `vpc_id = aws_vpc.main.id` |
| `aws_route_table.public` | `aws_internet_gateway.main` | `gateway_id = aws_internet_gateway.main.id` |
| `aws_route_table_association.public` | `aws_subnet.public` | `subnet_id = aws_subnet.public.id` |
| `aws_route_table_association.public` | `aws_route_table.public` | `route_table_id = aws_route_table.public.id` |

These are called **implicit** because you never wrote the word "dependency" anywhere — Terraform inferred the order purely from the `resource.name.attribute` references in the HCL.

---

## Task 4: Add a Security Group and EC2 Instance

```hcl
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
```

Using a `data "aws_ami"` lookup instead of a hardcoded AMI ID keeps the config portable across regions — hardcoded AMI IDs are region-specific and go stale over time.

**Verify:** After apply, the EC2 console shows `TerraWeek-Server` running with a public IPv4 address. SSH should succeed on port 22 and a basic HTTP request should succeed on port 80 (once a web server is installed — Terraform doesn't do that for you unless you add `user_data`).

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/303af58ca7ae3d1cc43341dffd8da37e11a2a5a9/Images/Day%2062/5.png)

---

## Task 5: Explicit Dependencies with `depends_on`

```hcl
resource "aws_s3_bucket" "logs" {
  bucket_prefix = "terraweek-app-logs-"

  depends_on = [aws_instance.main]

  tags = {
    Name = "TerraWeek-App-Logs"
  }
}
```
**`terraform plan` output** will show the S3 bucket ordered *after* the EC2 instance in the plan, even though nothing in the bucket's arguments references the instance.

**Implicit vs explicit dependencies, in my own words**

An **implicit dependency** is one Terraform discovers on its own, because one resource's argument literally points at another resource's attribute (`aws_vpc.main.id`, for example). Terraform builds its graph from these references automatically — you get the correct order for free just by writing normal HCL.

An **explicit dependency** is one *you* declare by hand with `depends_on`, because the two resources don't actually reference each other's attributes, but there's still a real-world ordering requirement Terraform has no way to see. You're telling Terraform "trust me, create B only after A," even though nothing in B's configuration mentions A.

**When would you use `depends_on` in real projects? Two examples:**

1. **IAM permissions that take effect outside of Terraform's visibility.** For example, an IAM role and policy might be attached, and a Lambda function needs that policy to actually be *in effect* before it runs, but the Lambda resource doesn't directly reference the policy attachment resource — only the role. Adding `depends_on = [aws_iam_role_policy_attachment.lambda_policy]` guarantees the permissions are live before the function is created.

2. **An application depends on infrastructure state that isn't expressed through a Terraform attribute.** For instance, an EC2 instance running a database migration script via `user_data` needs an RDS instance to be fully provisioned first, but the EC2 resource doesn't reference any RDS attribute directly (it connects to it at runtime via a hardcoded endpoint or environment variable). `depends_on = [aws_db_instance.main]` forces the ordering Terraform can't infer from the config alone.

**Visualizing the dependency graph**

```
terraform graph | dot -Tpng > graph.png
```

If Graphviz isn't installed, run just:

```
terraform graph
```

This prints DOT-format text like:
![]()


---

## Task 6: Lifecycle Rules and Destroy

```hcl
resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "TerraWeek-Server"
  }
}
```

**Changing the AMI and re-planning:**

```
terraform plan
```

Because of `create_before_destroy = true`, the plan shows:

```
# aws_instance.main must be replaced
+/- resource "aws_instance" "main" {
      ~ ami = "ami-old..." -> "ami-new..." # forces replacement
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Terraform provisions the **new** instance first, then destroys the old one — avoiding downtime where there'd otherwise be no server at all for a moment.

**Destroying everything**

```
terraform destroy
```

Terraform destroys resources in **reverse dependency order** — the opposite of creation order, since you can't delete a VPC while a subnet still lives inside it, or delete a subnet while an instance is still running in it. Rough destroy order for this stack:

```
aws_s3_bucket.logs
aws_instance.main
aws_route_table_association.public
aws_route_table.public
aws_security_group.main
aws_internet_gateway.main
aws_subnet.public
aws_vpc.main
```

**Verify** in the AWS console that the EC2 instance, S3 bucket, VPC, and all networking resources are gone — this avoids ongoing AWS charges.

**The three lifecycle arguments**

| Argument | What it does | When to use it |
|---|---|---|
| `create_before_destroy` | Provisions the replacement resource *before* destroying the old one, instead of the default destroy-then-create. | Anywhere a brief gap with no resource at all would cause downtime — EC2 instances behind a load balancer, or any resource other things actively depend on at runtime. |
| `prevent_destroy` | Blocks `terraform destroy` (and any plan that would destroy this resource) with an error, unless the block is removed first. | Protecting things that are extremely costly or dangerous to lose by accident — a production database, an S3 bucket holding critical logs or backups, a KMS key. |
| `ignore_changes` | Tells Terraform to ignore drift on specific attributes — it won't try to "correct" them back to what's in the `.tf` file. | When something outside Terraform legitimately changes a value — e.g. an autoscaling group's `desired_capacity` that a scaling policy adjusts at runtime, or tags added by another automated process — and you don't want every `plan` to show a false diff. |

---

## Summary: Implicit vs Explicit Dependencies

- **Implicit dependency** — inferred automatically from `resource.name.attribute` references in your HCL. This is the normal, preferred way dependencies form in Terraform; most of a well-written config's ordering comes from this alone.
- **Explicit dependency** — manually declared with `depends_on` when there's a real ordering requirement that isn't visible through any attribute reference. Used sparingly, and only when implicit references genuinely can't express the relationship.

Terraform's core promise: **you declare the desired end state, and it figures out the safe order to get there** — both when building and when tearing down.
