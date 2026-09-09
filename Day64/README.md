# Day 64 — Terraform State Management

Part of the **#90DaysOfDevOps** challenge. This day covers how Terraform tracks, stores, locks, and reconciles the real-world infrastructure it manages — using AWS S3 and DynamoDB as a remote backend.

---

## 🧠 Key Concepts

- **Terraform State** is Terraform's "inventory book" — it maps configuration to real infrastructure.
- **Remote State** (S3) allows teams to share a single source of truth instead of a local `terraform.tfstate` file.
- **State Locking** (DynamoDB) prevents two people/processes from modifying state at the same time.
- **Import** brings existing, manually-created infrastructure under Terraform's management without recreating it.
- **State Surgery** (`mv` / `rm`) lets you reorganize or stop tracking resources without touching real infrastructure.
- **Drift Detection** (`terraform plan`) catches when someone changes infrastructure outside of Terraform.

---

## ⚙️ Backend Configuration Used

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

---

## 🔑 Core Commands

```bash
# Inspect state
terraform show
terraform state list
terraform state show <resource>

# Migrate to remote backend
terraform init -migrate-state

# Import existing resources
terraform import <resource_address> <resource_id>

# Modify state safely
terraform state mv <old_address> <new_address>
terraform state rm <resource_address>

# Detect & fix drift
terraform plan
terraform apply

# Release a stuck lock (use with caution)
terraform force-unlock <LOCK_ID>
```

---

## 🏗️ Architecture

```
Terraform
   │
   ▼
Amazon S3 ──── terraform.tfstate + Version History

Terraform
   │
   ▼
DynamoDB ──── State Lock (terraweek-state-lock)
```

---

## ✅ Completion Status

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

## 📚 Tags

`#90DaysOfDevOps` `Terraform` `AWS` `InfrastructureAsCode` `DevOps` `Cloud` `StateManagement` `S3` `DynamoDB`
