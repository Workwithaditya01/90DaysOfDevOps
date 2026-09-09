# Day 64 — Terraform State Management

## Overview

Day 64 focused on **Terraform State Management**. Terraform State is used by Terraform to keep track of the infrastructure that it manages.

During this day, I worked with:

- Terraform State inspection
- Remote State using Amazon S3
- State locking using DynamoDB
- Terraform state locking testing
- Importing existing AWS resources
- Terraform State manipulation
- Configuration drift detection and correction

---

## Task 1 — Inspect Terraform State

### Objective

Understand what Terraform currently knows about the AWS infrastructure.

- Terraform **configuration** tells Terraform what infrastructure we *want*.
- Terraform **state** tells Terraform what infrastructure it is *currently tracking*.
- State can be thought of as Terraform's inventory book.

### Commands Used

Validate the configuration:

```bash
terraform validate
```

> Result: The configuration was successfully validated.

Display detailed information stored in the current state:

```bash
terraform show
```

List all resources currently tracked by Terraform:

```bash
terraform state list
```

Resources included:

```
data.aws_availability_zones.available
aws_instance.server
aws_internet_gateway.main
aws_route_table.public
aws_route_table_association.public
aws_security_group.main
aws_subnet.public
aws_vpc.main
```

Show detailed info about the EC2 instance:

```bash
terraform state show aws_instance.server
```

- **Instance Type:** `t3.micro`

Show detailed info about the VPC:

```bash
terraform state show aws_vpc.main
```

- **CIDR Block:** `10.0.0.0/16`

### What I Learned

Terraform State maintains the relationship:

```
Terraform Configuration
        ↓
   Terraform State
        ↓
   AWS Infrastructure
```

---

## Task 2 — Remote State Using S3 and DynamoDB

### Objective

Move Terraform state from the local computer to a centralized remote backend. A local state file works well for individual practice, but teams need a shared and protected state.

- **S3** → stores Terraform state
- **DynamoDB** → provides state locking
- **S3 Versioning** → maintains previous versions of the state

### Step 1 — Create S3 Bucket

An S3 bucket was manually created for storing the Terraform state.

- **Region:** `ap-south-1`

### Step 2 — Enable S3 Versioning

Versioning was enabled on the S3 bucket, allowing previous versions of the Terraform state to be retained — an extra safety mechanism if the state is accidentally changed or damaged.

### Step 3 — Create DynamoDB Table

A DynamoDB table was created to prevent multiple Terraform processes from modifying the state simultaneously.

- **Table name:** `terraweek-state-lock`
- **Partition Key:** `LockID`
- **Type:** `String`

### Step 4 — Configure S3 Backend

```hcl
terraform {
  backend "s3" {
    bucket         = "YOUR-ACTUAL-BUCKET-NAME"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

**Meaning of each field:**

| Field | Meaning |
|---|---|
| `bucket` | The S3 bucket where the Terraform state is stored |
| `key` | The path where the Terraform state is stored (`dev/terraform.tfstate`) |
| `region` | The AWS region where the backend is configured (`ap-south-1`) |
| `dynamodb_table` | The DynamoDB table used for state locking (`terraweek-state-lock`) |
| `encrypt` | Enables encryption for the state stored in S3 |

### Step 5 — Migrate Local State to S3

```bash
terraform init -migrate-state
```

This migrated the existing local Terraform state to the S3 remote backend.

> **Why `-migrate-state` instead of `-reconfigure`?**
> An existing local state needed to be moved to the newly configured remote backend.

### Step 6 — Verify Remote State

Expected state location: `dev/terraform.tfstate`

Verify that moving the state caused no unwanted infrastructure changes:

```bash
terraform plan
```

> Expected result: **No changes.**

### What I Learned

- S3 acts as the central storage location for Terraform state.
- DynamoDB provides state locking.
- S3 versioning keeps previous versions of the state.
- Remote state is important when working with Terraform in a team.

### Real-Life Analogy

| Concept | Analogy |
|---|---|
| Local State | One person keeps an inventory notebook on their desk |
| Remote State | The company keeps the inventory notebook in a shared secure room |
| DynamoDB Lock | Only one person can use the notebook at a time |
| S3 Versioning | Previous versions of the notebook are preserved |

---

## Task 3 — Test Terraform State Locking

### Objective

Verify that Terraform prevents multiple operations from modifying the same state at the same time.

### How It Was Tested

Two Git Bash terminals were opened inside the Day 64 Terraform directory.

**Terminal 1:**

```bash
terraform apply
```

The Terraform operation was kept active.

**Terminal 2:**

```bash
terraform apply
```

The second process attempted to access the same remote state. Terraform detected that the state was already locked and displayed an error similar to:

```
Error acquiring the state lock
```

Terraform also displayed information about the existing lock, including:

- Lock ID
- Path
- Operation
- Who
- Terraform Version
- Created

This confirmed that state locking was working.

### Stale Locks

Sometimes a Terraform process can crash or terminate unexpectedly while holding a state lock. In that situation, the lock may remain.

```bash
terraform force-unlock <LOCK_ID>
```

> **Important:** `force-unlock` should only be used when I am completely sure that no other Terraform operation is currently running. Removing a legitimate active lock can cause state corruption or conflicting operations.

### What I Learned

State locking prevents multiple users or Terraform processes from changing the same state simultaneously — especially important in team environments.

### Real-Life Analogy

Imagine there is only one company inventory register. If two employees edit it at exactly the same time, information could be lost or overwritten. The lock ensures that one person works with the register at a time.

---

## Task 4 — Import an Existing AWS Resource

### Objective

Practice importing an AWS resource that already existed into Terraform state.

### Why Import Is Required

Sometimes infrastructure already exists in AWS before Terraform is introduced. Instead of deleting the existing resource and creating a new one, Terraform can import the existing resource into its state.

### Step 1 — Create an S3 Bucket Manually

An S3 bucket was created manually through AWS, separate from the Terraform backend bucket.

### Step 2 — Add the Resource to Terraform Configuration

```hcl
resource "aws_s3_bucket" "imported" {
  bucket = "YOUR-BUCKET-NAME"
}
```

### Step 3 — Validate Configuration

```bash
terraform validate
```

### Step 4 — Import the Existing Bucket

```bash
terraform import aws_s3_bucket.imported YOUR-BUCKET-NAME
```

This command tells Terraform: *"The AWS resource already exists. Start tracking it."*

### Step 5 — Verify the State

```bash
terraform state list
```

The imported resource appeared as `aws_s3_bucket.imported`. Detailed information was checked using:

```bash
terraform state show aws_s3_bucket.imported
```

### Step 6 — Run Plan

```bash
terraform plan
```

> Expected result: **No changes.**

This confirmed that Terraform was successfully tracking the existing resource.

### What I Learned

Terraform import does **not** create a new AWS resource — it connects an already-existing AWS resource with Terraform state.

**Important difference:**

| Command | Effect |
|---|---|
| `terraform apply` | Creates or modifies infrastructure according to Terraform configuration |
| `terraform import` | Adds an existing infrastructure resource to Terraform state |

---

## Task 5 — Terraform State Surgery

### Objective

Practice safely modifying Terraform state without unnecessarily deleting AWS infrastructure.

### State Move

```bash
terraform state mv aws_s3_bucket.imported aws_s3_bucket.application
```

This changes the resource address inside Terraform state. It does **not** delete the actual S3 bucket.

The Terraform configuration was then updated to use `aws_s3_bucket.application`, and verified with:

```bash
terraform plan
```

### State Remove

```bash
terraform state rm aws_s3_bucket.application
```

> `terraform state rm` does **NOT** delete the actual AWS resource. It only tells Terraform: *"Stop tracking this resource."*

### Re-Import

```bash
terraform import aws_s3_bucket.application YOUR-BUCKET-NAME
```

Then verify again:

```bash
terraform plan
```

### Important Commands

| Command | Effect |
|---|---|
| `terraform state mv` | Moves or renames a resource address in Terraform state (does not delete the AWS resource) |
| `terraform state rm` | Removes a resource from Terraform state (does not delete the AWS resource) |
| `terraform import` | Adds an existing AWS resource to Terraform state (does not create a new AWS resource) |

### Real-Life Analogy

| Command | Analogy |
|---|---|
| `state mv` | Change the name/location of an item in the inventory |
| `state rm` | Remove the item from the inventory record, but the physical item still exists |
| `import` | Find an existing physical item and add it to the inventory system |

---

## Task 6 — Detect and Fix Configuration Drift

### Objective

Understand configuration drift — when the actual AWS infrastructure becomes different from what Terraform configuration expects.

### Example

- Terraform configuration expected: `EC2 Name = terraweek-server`
- The Name tag was manually changed through the AWS Console to: `EC2 Name = drift-test-server`

```
Terraform Configuration → Expected Configuration
AWS Infrastructure      → Actual Configuration
```

These two were no longer matching — this is called **configuration drift**.

### Step 1 — Check Current State

```bash
terraform state show aws_instance.server
```

The current Name tag was noted.

### Step 2 — Change AWS Manually

The same EC2 instance was opened in the AWS Console and the Name tag was manually changed.

### Step 3 — Detect Drift

```bash
terraform plan
```

Terraform detected the difference between the configuration and the actual AWS infrastructure. The plan showed an in-place change to the EC2 resource.

### Step 4 — Reconcile the Drift

```bash
terraform apply
```

Terraform changed the infrastructure back to the configuration defined in Terraform.

### Step 5 — Verify

```bash
terraform plan
```

> Expected result: **No changes.** This confirmed that the drift had been successfully corrected.

> **Important:** If `terraform plan` shows an unexpected resource replacement, such as `-/+ aws_instance.server`, or unrelated infrastructure changes, it should not be blindly applied. The plan should always be reviewed before running `terraform apply`.

### What I Learned

- Terraform can detect when infrastructure has been manually changed outside Terraform.
- `terraform plan` compares the desired configuration with the actual infrastructure and identifies differences.
- `terraform apply` can reconcile the infrastructure with the Terraform configuration.

### Real-Life Analogy

Imagine a company inventory says `Laptop → DevOps Department`, but someone physically moves the laptop to `Production Department`. The inventory and reality no longer match — similar to Terraform configuration drift. Terraform helps detect and correct the difference.

---

## Important Terraform State Commands

| Command | Description |
|---|---|
| `terraform show` | Displays the current Terraform state |
| `terraform state list` | Lists resources tracked in Terraform state |
| `terraform state show` | Displays detailed information about a specific resource |
| `terraform state mv` | Moves a resource to another Terraform state address |
| `terraform state rm` | Removes a resource from Terraform state without deleting the actual infrastructure |
| `terraform import` | Imports an existing resource into Terraform state |
| `terraform force-unlock` | Removes a Terraform state lock when it is confirmed to be stale |
| `terraform plan` | Shows differences between desired configuration and actual infrastructure |
| `terraform apply` | Applies the planned infrastructure changes |

---

## Local State vs Remote State

### Local State

Terraform state is stored on the local machine (e.g. `terraform.tfstate`).

**Advantages:**
- Simple for individual practice
- No remote infrastructure required

**Disadvantages:**
- Difficult for teams
- State can be lost if the machine fails
- No centralized state management

### Remote State

Terraform state is stored remotely:

- **S3** → State Storage
- **DynamoDB** → State Locking
- **S3 Versioning** → State Version History

```
Terraform
   │
   ▼
Amazon S3
   │
   ├── terraform.tfstate
   │
   └── Version History

Terraform
   │
   ▼
DynamoDB
   │
   └── State Lock
```

---

## Day 64 Key Learnings

- Terraform state keeps track of infrastructure.
- `terraform show` can be used to inspect state.
- `terraform state list` displays tracked resources.
- `terraform state show` provides detailed resource information.
- S3 can be used as a remote Terraform backend.
- S3 versioning provides previous state versions.
- DynamoDB can provide state locking.
- State locking prevents simultaneous Terraform operations.
- `terraform force-unlock` can remove a stale lock.
- Existing AWS resources can be imported using `terraform import`.
- `terraform state mv` changes a resource address without deleting the infrastructure.
- `terraform state rm` removes a resource from Terraform state without deleting the infrastructure.
- Terraform can detect configuration drift.
- `terraform plan` helps identify infrastructure differences.
- `terraform apply` can reconcile infrastructure with the Terraform configuration.

---

## Final Day 64 Workflow

```
Inspect State
   ↓
terraform show
   ↓
terraform state list
   ↓
Configure Remote Backend
   ↓
S3 + DynamoDB
   ↓
terraform init -migrate-state
   ↓
Test State Locking
   ↓
Import Existing Resource
   ↓
terraform import
   ↓
Perform State Surgery
   ↓
state mv / state rm / import
   ↓
Create Configuration Drift
   ↓
terraform plan
   ↓
terraform apply
   ↓
terraform plan
   ↓
No Changes
```

---

## Day 64 Completion Status

- [x] Terraform State Inspection
- [x] S3 Remote Backend
- [x] S3 Versioning
- [x] DynamoDB State Locking
- [x] State Lock Testing
- [x] Terraform Import
- [x] State Move
- [x] State Remove
- [x] Resource Re-import
- [x] Configuration Drift Detection
- [x] Drift Reconciliation

---

## Conclusion

Day 64 focused on understanding how Terraform manages infrastructure state. The most important concept I learned is that Terraform is not only an Infrastructure as Code tool — it also needs to maintain an accurate record of the infrastructure it manages.

I learned how to inspect Terraform state, move state to a remote S3 backend, protect it with state locking, import existing infrastructure, safely manipulate state, and detect configuration drift. These concepts are important for real-world Terraform usage, especially when working with teams and production infrastructure.

**Day 64 — Completed ✅**

`#90DaysOfDevOps` `Terraform` `AWS` `InfrastructureAsCode` `DevOps` `Cloud` `StateManagement` `S3` `DynamoDB`