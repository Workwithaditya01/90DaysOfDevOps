# Day 61 — Introduction to Terraform and My First AWS Infrastructure

## 1. Infrastructure as Code — In My Own Words

Infrastructure as Code (IaC) means describing the servers, networks, and cloud
resources I need in a text file instead of clicking around a cloud console.
That file becomes the single source of truth: I can version it in Git, review
it like any other code, and run it again to get the exact same environment
every time. It matters in DevOps because infrastructure stops being something
only one person "remembers how to set up" — it becomes reproducible,
reviewable, and automatable, which is exactly what CI/CD pipelines need to
work end to end.

Compared to manually creating resources in the AWS console, IaC solves the
problem of **drift and tribal knowledge**. Manually-built infrastructure is
hard to reproduce (What exact settings did I click three months ago?), hard
to audit (no history of who changed what), and easy to break when someone
forgets a step. With Terraform, the `.tf` files *are* the documentation, the
change history lives in Git, and spinning up a second identical environment
(staging, DR, another region) is just running `terraform apply` again instead
of repeating dozens of manual clicks.

### Terraform vs CloudFormation vs Ansible vs Pulumi

- **Terraform vs CloudFormation** — CloudFormation is AWS-only and tightly
  coupled to AWS's own resource model. Terraform uses providers, so the same
  workflow and language can manage AWS, Azure, GCP, Kubernetes, GitHub, etc.
  in one codebase.
- **Terraform vs Ansible** — Ansible is primarily a **configuration
  management** tool (installing packages, editing config files, restarting
  services on machines that already exist). Terraform is a
  **provisioning** tool (creating the machines, networks, and cloud
  resources themselves). In practice teams often use both: Terraform to
  create the VM, Ansible to configure what runs inside it.
- **Terraform vs Pulumi** — Pulumi lets you write infrastructure in real
  programming languages (Python, TypeScript, Go) instead of HCL, which gives
  you loops, functions, and full IDE support natively. Terraform's HCL is
  purpose-built and simpler to read for infra-only use cases, but less
  flexible for complex programmatic logic.

### "Declarative" and "Cloud-Agnostic"

**Declarative** means I describe the *end state* I want ("I want one S3
bucket and one t2.micro EC2 instance") rather than writing step-by-step
imperative instructions for *how* to get there. Terraform figures out the
sequence of API calls needed on its own.

**Cloud-agnostic** means Terraform's core language and workflow (`init`,
`plan`, `apply`, `destroy`) stay the same no matter which cloud I'm targeting.
The actual resource types differ per provider (AWS vs Azure vs GCP), but I'm
not learning a completely new tool for each cloud — just a new provider
plugin.

---

## 2. Environment Setup

```bash
terraform -version
aws sts get-caller-identity
```

- `terraform -version` confirmed the Terraform CLI was installed correctly.
- `aws configure` set up my Access Key ID, Secret Access Key, default region
  (`ap-south-1`), and output format (`json`).
- `aws sts get-caller-identity` confirmed the CLI was authenticated correctly
  by returning my AWS Account ID, User ID, and ARN.

**[Insert screenshot: terraform -version + aws sts get-caller-identity output]**

---

## 3. First Terraform Config — S3 Bucket

`main.tf` (see repo) defines:
- a `terraform` block declaring the `hashicorp/aws` provider requirement
- a `provider "aws"` block pinned to `ap-south-1`
- an `aws_s3_bucket` resource with a globally unique bucket name

```bash
terraform init
terraform plan
terraform apply
```

**What `terraform init` downloaded:** it read the `required_providers` block,
went to the Terraform Registry, and downloaded the `hashicorp/aws` provider
plugin (the code that knows how to translate my HCL resource blocks into real
AWS API calls). It stored that plugin locally and created a
`.terraform.lock.hcl` file to pin the exact provider version for reproducible
builds.

**What `.terraform/` contains:** the downloaded provider plugin binaries
(under `.terraform/providers/...`), plus internal Terraform metadata used
during `plan`/`apply`. It's machine-specific and regenerable, which is why it
belongs in `.gitignore` rather than being committed.

**[Insert screenshot: bucket visible in AWS S3 console]**

---

## 4. Adding an EC2 Instance

Added an `aws_instance` resource to the same `main.tf`:
- AMI: `ami-0f5ee92e2d63afc18` (Amazon Linux 2, ap-south-1)
- Instance type: `t2.micro`
- Tag: `Name = "TerraWeek-Day1"`

```bash
terraform plan
terraform apply
```

`terraform plan` showed **1 to add, 0 to change, 0 to destroy** — only the
EC2 instance.

**How Terraform knew the S3 bucket already existed:** Terraform doesn't
re-scan AWS on every run to figure out what exists — it compares my `.tf`
configuration against the **state file** (`terraform.tfstate`), which already
recorded the S3 bucket's ID and attributes from the previous apply. Since the
bucket's config in `main.tf` hadn't changed, Terraform's plan showed no diff
for it and only planned to create the new resource (the EC2 instance) that
wasn't yet tracked in state.

**[Insert screenshot: EC2 instance running with Name tag "TerraWeek-Day1" in AWS console]**

---

## 5. Understanding the State File

```bash
terraform show
terraform state list
terraform state show aws_s3_bucket.terraweek_bucket
terraform state show aws_instance.terraweek_instance
```

- `terraform show` — printed a human-readable dump of every resource
  currently tracked in state, with all their resolved attribute values
  (ARNs, IDs, tags, etc.), not just what I wrote in `main.tf`.
- `terraform state list` — printed just the resource addresses being
  managed, e.g. `aws_s3_bucket.terraweek_bucket` and
  `aws_instance.terraweek_instance`.
- `terraform state show <resource>` — printed the full, detailed attribute
  set for that one resource exactly as AWS returned it (public IP, AZ,
  security groups, ARN, bucket region, etc.).

**What the state file stores:** for every resource it manages, Terraform
stores the resource's real-world ID, every attribute AWS returned (including
values I never set explicitly, like ARNs or generated IDs), metadata about
dependencies between resources, and the provider that manages it. It's
essentially Terraform's map between "the block of HCL I wrote" and "the
actual object living in AWS."

**Why I should never manually edit `terraform.tfstate`:** the file is a
precise mirror of real infrastructure. Hand-editing it (or deleting a line)
doesn't change AWS — it just makes Terraform's internal picture wrong. On the
next `plan`/`apply` Terraform will either try to "fix" real infrastructure
based on bad data, orphan resources it can no longer track, or destroy/recreate
things unexpectedly. Any change should go through `terraform apply`,
`terraform import`, or `terraform state mv/rm` — never a text editor.

**Why the state file should never be committed to Git:** it often contains
sensitive data in plaintext (resource IDs, IPs, sometimes secrets/passwords
passed as resource attributes), and it changes on every apply, which would
cause constant merge conflicts and let a stale committed copy silently
diverge from real infrastructure. In a team setting, state should live in a
shared remote backend (e.g., an S3 bucket + DynamoDB lock table) instead of
Git.

---

## 6. Modify, Plan, and Destroy

Changed the EC2 tag from `"TerraWeek-Day1"` to `"TerraWeek-Modified"` and ran
`terraform plan`.

**Reading the plan symbols:**
- `~` = an **in-place update** — the resource stays, only some attributes
  change.
- `+` = a resource will be **created**.
- `-` = a resource will be **destroyed**.
- `-/+` = **destroy and recreate** (used when an attribute can't be changed
  in place, e.g. changing an EC2 instance's AMI).

For a tag change like this, the plan showed `~` — tags can be updated
in place via the AWS API, so Terraform just calls `ModifyTags` under the
hood rather than destroying and recreating the whole instance.

```bash
terraform apply     # applied the tag change
terraform destroy   # tore everything down, typed 'yes' to confirm
```

---

## 7. Terraform Command Reference

| Command | What it does |
|---|---|
| `terraform init` | Initializes the working directory: downloads required provider plugins and sets up the backend for state storage. Must be run first in any new/cloned project. |
| `terraform plan` | Compares the `.tf` config against the current state file and shows exactly what will be created, changed, or destroyed — without making any real changes. |
| `terraform apply` | Executes the plan against the real cloud provider, creating/updating/destroying actual resources, and updates the state file to match. |
| `terraform destroy` | Deletes every resource currently tracked in the state file, in the correct dependency order. |
| `terraform show` | Prints a human-readable view of the current state (or a saved plan file). |
| `terraform state list` | Lists the addresses of all resources currently tracked in state. |
| `terraform fmt` | Auto-formats `.tf` files to the canonical style. |
| `terraform validate` | Checks configuration syntax and internal consistency without contacting the cloud provider. |

---

## 8. Key Takeaway

The state file is what turns Terraform from "a script that runs AWS API
calls" into a true infrastructure management tool — it's the memory that
lets `plan` know what already exists, lets `apply` make only the necessary
changes, and lets `destroy` clean up precisely what it created. Losing or
corrupting it means losing Terraform's ability to safely manage that
infrastructure, which is why it's treated as sensitive, machine-managed
state rather than source code.
