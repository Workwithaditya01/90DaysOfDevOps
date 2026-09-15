# Day 66 – Provision an EKS Cluster with Terraform Modules

Part of a **90 Days of DevOps** learning journey. This project provisions an **Amazon EKS cluster** using **Terraform modules**, deploys an **Nginx** workload on Kubernetes, and exposes it publicly via an **AWS Load Balancer**.

---

## 📌 Overview

This project uses Infrastructure as Code (IaC) to:

- Provision a custom AWS VPC with public/private subnets and a NAT Gateway
- Spin up a managed Amazon EKS cluster via Terraform modules
- Deploy an Nginx application to the cluster
- Expose it to the internet through a Kubernetes `LoadBalancer` service

Full write-up, troubleshooting notes, and lessons learned are in [`Day-66-EKS-Terraform.md`](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a937c516f6aa3a1f7276a47daa6bc32873870447/Day66/day-66-eks-terraform.md).

---

## 🛠️ Tech Stack

| Category        | Tools                              |
|-----------------|-------------------------------------|
| Cloud Provider  | AWS (VPC, EC2, EKS, ELB)            |
| IaC             | Terraform                           |
| Orchestration   | Kubernetes, kubectl                 |
| Workload        | Nginx                               |

---

## 📁 Project Structure

```text
Day-66/
│
├── providers.tf
├── vpc.tf
├── eks.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
└── k8s/
    └── nginx-deployment.yaml
```

---

## 🏗️ Infrastructure

- **VPC:** `10.0.0.0/16`, 2 AZs, 2 public + 2 private subnets, NAT Gateway
- **EKS Cluster:** `terraweek-eks` in `ap-south-1`
- **Node Group:** Managed, Amazon Linux 2023, `t3.micro`, 2 nodes
- **API Endpoint:** Public

---

## 🚀 Usage

### 1. Provision infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 2. Configure kubectl

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name terraweek-eks
```

### 3. Deploy Nginx

```bash
kubectl apply -f k8s/nginx-deployment.yaml
kubectl get deployments
kubectl get svc
```

Access the app using the external DNS name shown for `nginx-service`.

### 4. Cleanup

```bash
kubectl delete service nginx-service
kubectl delete deployment nginx
terraform destroy
```

---

## 🐛 Known Issue: Pods Stuck in `Pending`

With only 1 worker node, system pods (`aws-node`, `kube-proxy`, CoreDNS) consumed all available pod capacity, leaving none for Nginx.

**Fix:** Scale the managed node group's desired capacity from 1 → 2 nodes.

```bash
kubectl describe node <node-name>   # inspect allocatable pod capacity
kubectl get pods -A -o wide         # confirm scheduling issue
```

---

## 🧠 Key Takeaways

- Terraform modules greatly simplify provisioning complex, multi-resource AWS infrastructure.
- EKS separates the managed control plane from worker nodes, which you scale independently.
- A `Pending` pod isn't always an app problem — check node capacity, resources, and scheduling constraints first.
- Understanding the infrastructure underneath your workload is essential for effective troubleshooting.

---

## 📚 Related

- [Day 66 full write-up](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a937c516f6aa3a1f7276a47daa6bc32873870447/Day66/day-66-eks-terraform.md)

---

#DevOps #AWS #EKS #Terraform #Kubernetes #InfrastructureAsCode #90DaysOfDevOps #CloudComputing #LearningInPublic
