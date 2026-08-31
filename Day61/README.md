# terraform-basics

First Terraform project from **Day 61 — Introduction to Terraform and Your
First AWS Infrastructure** (TerraWeek / #90DaysOfDevOps).

This project uses Terraform to provision a small, throwaway AWS environment
consisting of:

- One **S3 bucket**
- One **EC2 instance** (`t2.micro`, Amazon Linux 2)

It's meant purely as a learning exercise for the core Terraform workflow:
`init` → `plan` → `apply` → inspect state → modify → `destroy`.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- An AWS account with programmatic access (Access Key ID + Secret Access Key)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured:

  ```bash
  aws configure
  aws sts get-caller-identity   # confirms your credentials work
  ```

## Project structure

```
terraform-basics/
├── main.tf         # provider, S3 bucket, and EC2 instance resources
├── .gitignore       # excludes state files and provider binaries from Git
└── README.md
```

## Setup

1. Clone this project and move into it:

   ```bash
   cd terraform-basics
   ```

2. Open `main.tf` and update the S3 bucket name — bucket names must be
   **globally unique** across all of AWS:

   ```hcl
   resource "aws_s3_bucket" "terraweek_bucket" {
     bucket = "terraweek-<yourname>-2026"  # <-- change this
   }
   ```

3. If you're not deploying to `ap-south-1`, update the `provider "aws"`
   region and swap the EC2 `ami` for a valid Amazon Linux 2 AMI ID in your
   region.

## Usage

```bash
# Download the AWS provider plugin
terraform init

# Preview what will be created
terraform plan

# Create the resources (type 'yes' to confirm)
terraform apply
```

Inspect what Terraform is managing:

```bash
terraform show                                  # full current state, human-readable
terraform state list                            # list of managed resources
terraform state show aws_s3_bucket.terraweek_bucket
terraform state show aws_instance.terraweek_instance
```

Make a change (e.g. edit the EC2 `Name` tag in `main.tf`), then:

```bash
terraform plan     # review the diff before applying
terraform apply
```

When you're done, tear everything down so you don't get billed for an idle
EC2 instance:

```bash
terraform destroy
```

## Useful commands

| Command | Purpose |
|---|---|
| `terraform fmt` | Auto-format `.tf` files to canonical style |
| `terraform validate` | Check config syntax without contacting AWS |
| `terraform init` | Download providers, set up the working directory |
| `terraform plan` | Preview changes |
| `terraform apply` | Create/update real infrastructure |
| `terraform destroy` | Tear down everything Terraform manages here |

## Notes

- `terraform.tfstate` and `.terraform/` are intentionally excluded from Git
  via `.gitignore` — the state file can contain sensitive resource data and
  should never be committed or hand-edited.
- This config uses local state (a `terraform.tfstate` file on disk). For
  team use, configure a remote backend (e.g. S3 + DynamoDB for locking)
  instead.

## Related

Full write-up and notes for this exercise: [`day-61-terraform-intro.md`](../day-61-terraform-intro.md)
