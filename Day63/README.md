# Day 63 — Terraform Variables, Outputs, Data Sources & Expressions

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)
![DevOps](https://img.shields.io/badge/90DaysOfDevOps-Day%2063-blue)

## 📌 Overview

Day 63 of my #90DaysOfDevOps journey focused on making Terraform configurations more **dynamic, reusable, and maintainable**.

In Day 62, the AWS infrastructure was created using many hardcoded values.

In Day 63, I converted the configuration into a more flexible Terraform setup using:

- Variables
- Variable files
- Outputs
- Data Sources
- Locals
- Common Tags
- Terraform Functions
- Expressions
- Conditional Expressions

The infrastructure is deployed on AWS using Terraform.

---

## 🎯 Objectives

The main objectives of Day 63 were:

- Understand Terraform input variables
- Use different variable types
- Store variable values using `.tfvars`
- Create environment-specific configurations
- Use Terraform outputs
- Retrieve existing AWS information using Data Sources
- Dynamically select an Availability Zone
- Dynamically retrieve an Amazon Linux AMI
- Create reusable local values
- Apply common tags to AWS resources
- Use Terraform built-in functions
- Practice expressions and conditional expressions
- Make the infrastructure more reusable

---

## 🏗️ Infrastructure

The Terraform configuration creates the following AWS infrastructure:

```text
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
   10.0.1.0/24                   │
          │                      │
          ▼                      │
    Route Table ◄────────────────┘
          │
          ▼
   Security Group
   22 / 80 / 443
          │
          ▼
       EC2
      Server
