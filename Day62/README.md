# Day 62 — Providers, Resources and Dependencies

Part of the **#90DaysOfDevOps** / **#TerraWeek** challenge with TrainWithShubham.

Builds a complete, connected AWS networking stack with Terraform — VPC, subnet, internet gateway, route table, security group, and an EC2 instance — and explores how Terraform figures out the correct order to create (and destroy) resources.

## What this builds

- A VPC (`10.0.0.0/16`)
- A public subnet (`10.0.1.0/24`) with auto-assigned public IPs
- An internet gateway attached to the VPC
- A route table sending `0.0.0.0/0` traffic to the internet gateway, associated with the subnet
- A security group allowing inbound SSH (22) and HTTP (80), and all outbound traffic
- An EC2 `t2.micro` instance (Amazon Linux 2) inside the subnet, using the security group
- An S3 bucket for logs, created only after the EC2 instance via `depends_on`

## Project structure

```
terraform-aws-infra/
├── providers.tf   # terraform + provider block, pinned to aws ~> 5.0
├── main.tf        # VPC, subnet, IGW, route table, SG, EC2 instance, S3 bucket
└── README.md      # this file
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.0`
- An AWS account with credentials configured (`aws configure` or environment variables)
- (Optional) [Graphviz](https://graphviz.org/) installed, to render the dependency graph as an image

## Usage

```bash
# initialize the working directory and download the AWS provider
terraform init

# format the code consistently
terraform fmt

# preview what will be created
terraform plan

# create the infrastructure
terraform apply

# visualize the dependency graph
terraform graph | dot -Tpng > graph.png
# (if dot isn't installed, run `terraform graph` and paste the output into webgraphviz.com)

# tear everything down when you're done, to avoid ongoing AWS charges
terraform destroy
```

## Key concepts covered

- **Provider version constraints** — the difference between `~> 5.0`, `>= 5.0`, and `= 5.0.0`, and what `.terraform.lock.hcl` is for.
- **Implicit dependencies** — how Terraform infers creation order automatically from `resource.name.attribute` references (e.g. `aws_vpc.main.id`).
- **Explicit dependencies** — using `depends_on` when a real ordering requirement exists but isn't visible through any attribute reference.
- **Lifecycle rules** — `create_before_destroy`, `prevent_destroy`, and `ignore_changes`, and when each one matters.
- **Destroy order** — Terraform tears resources down in reverse dependency order.

Full write-up, explanations, and the rendered dependency graph are in [`day-62-providers-resources.md`](./day-62-providers-resources.md).

## Cleanup

Always run `terraform destroy` after verifying the setup in the AWS console — this stack includes an EC2 instance and will incur charges if left running.

---
`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`
