# Day 66 – Provision an EKS Cluster with Terraform Modules

## 📌 Overview

Today I worked on provisioning an **Amazon EKS cluster using Terraform modules**.

The goal was to use Infrastructure as Code (IaC) to create the required AWS infrastructure, deploy a Kubernetes workload, and expose the application through an AWS Load Balancer.

---

## 🎯 Objectives

* Create an AWS VPC using Terraform.
* Create public and private subnets.
* Configure a NAT Gateway.
* Provision an Amazon EKS cluster.
* Create managed worker nodes.
* Connect the cluster using `kubectl`.
* Deploy an Nginx application.
* Expose Nginx using a Kubernetes LoadBalancer.
* Troubleshoot Kubernetes scheduling issues.
* Understand the complete infrastructure flow.

---

## 🛠️ Technologies Used

* **AWS**
* **Amazon EKS**
* **Terraform**
* **Kubernetes**
* **kubectl**
* **Nginx**
* **EC2**
* **VPC**
* **NAT Gateway**
* **AWS Load Balancer**

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

# 🏗️ Infrastructure Provisioning

Terraform was used to provision the AWS infrastructure.

### VPC

The VPC was configured with:

* CIDR: `10.0.0.0/16`
* 2 Availability Zones
* 2 Public Subnets
* 2 Private Subnets
* NAT Gateway
* DNS Hostnames enabled
* DNS Support enabled

The private subnets were used for the EKS worker nodes.

---

# ☸️ Amazon EKS

The EKS cluster was created using the Terraform AWS EKS module.

The cluster configuration included:

* Cluster name: `terraweek-eks`
* Region: `ap-south-1`
* Managed Node Group
* Amazon Linux 2023 AMI
* `t3.micro` worker nodes
* 2 worker nodes
* Public Kubernetes API endpoint

Terraform modules made it possible to create the required EKS infrastructure without manually creating every AWS resource.

---

# 🔐 Connecting to the EKS Cluster

After the cluster was created, I configured `kubectl` to communicate with EKS.

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name terraweek-eks
```

Then verified the connection:

```bash
kubectl cluster-info
```

And checked the worker nodes:

```bash
kubectl get nodes
```

The cluster successfully showed **2 Ready worker nodes**.

---

# 🚀 Deploying Nginx

I created a Kubernetes Deployment with 2 Nginx replicas.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

The deployment was applied using:

```bash
kubectl apply -f k8s/nginx-deployment.yaml
```

Verification:

```bash
kubectl get deployments
```

Expected result:

```text
NAME    READY   UP-TO-DATE   AVAILABLE
nginx   2/2     2            2
```

---

# 🌐 Exposing Nginx

A Kubernetes `LoadBalancer` service was created to expose Nginx outside the cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

Check the service:

```bash
kubectl get svc
```

AWS automatically provisioned an external Load Balancer.

The Nginx application could then be accessed through the Load Balancer DNS name.

---

# 🐛 Problem I Faced

One of the main problems I faced was that the **Nginx pods were stuck in the `Pending` state**.

Initially, the cluster had only one worker node.

When I checked the node's allocatable resources, I found that the node had a very limited **pod capacity**.

The available pod slots were already being used by Kubernetes system components such as:

* `aws-node`
* `kube-proxy`
* CoreDNS pods

Because there was no available pod capacity for the Nginx workload, Kubernetes could not schedule the Nginx pods.

### 🔎 Troubleshooting

I checked the nodes:

```bash
kubectl get nodes
```

Then inspected the node's allocatable resources:

```bash
kubectl describe node <node-name>
```

I also checked all pods:

```bash
kubectl get pods -A -o wide
```

This helped identify that the issue was related to **pod scheduling capacity rather than the Nginx application itself**.

### ✅ Solution

I increased the EKS managed node group's desired capacity from 1 to 2.

After the second worker node became available, Kubernetes successfully scheduled the Nginx pods.

```bash
kubectl get nodes
```

Result:

```text
2 nodes → Ready
```

Then:

```bash
kubectl get pods
```

The Nginx pods were successfully running.

---

# 🔍 Final Verification

### Check nodes

```bash
kubectl get nodes
```

### Check all pods

```bash
kubectl get pods -A
```

### Check deployment

```bash
kubectl get deployment nginx
```

### Check service

```bash
kubectl get svc nginx-service
```

The final setup successfully had:

* 2 EKS worker nodes
* 2 Nginx replicas
* Nginx pods in `Running` state
* Kubernetes LoadBalancer
* External AWS Load Balancer

---

# 🧠 What I Learned

### 1. Terraform Modules

Terraform modules can simplify the process of provisioning complex AWS infrastructure.

### 2. Amazon EKS

EKS provides a managed Kubernetes control plane while worker nodes run the actual workloads.

### 3. Kubernetes Scheduling

A pod being `Pending` does not necessarily mean the application has a problem.

It is important to check:

* Node availability
* CPU and memory
* Pod capacity
* Taints
* Scheduling events
* Resource requests and limits

### 4. Troubleshooting

The biggest lesson from today's task was to **look at the infrastructure underneath the application when troubleshooting**.

### 5. Infrastructure as Code

Terraform allows infrastructure to be created and managed through configuration files instead of manually creating resources through the AWS Console.

---

# 🔄 Architecture Flow

```text
                    Terraform
                        │
                        ▼
                  AWS VPC
              ┌─────────┴─────────┐
              │                   │
        Public Subnets       Private Subnets
              │                   │
        NAT Gateway                │
                                  ▼
                           Amazon EKS
                         ┌─────────────┐
                         │ Control     │
                         │ Plane       │
                         └──────┬──────┘
                                │
                   ┌────────────┴────────────┐
                   ▼                         ▼
              Worker Node 1             Worker Node 2
                   │                         │
                   └──────────┬──────────────┘
                              ▼
                       Nginx Deployment
                         ┌──────────┐
                         │ Replica 1│
                         │ Replica 2│
                         └────┬─────┘
                              │
                              ▼
                     LoadBalancer Service
                              │
                              ▼
                       AWS Load Balancer
                              │
                              ▼
                       🌐 Nginx Website
```

---

# 📸 Screenshots to Include

For documentation, I captured/plan to capture:

1. Terraform infrastructure creation
2. `kubectl get nodes`
3. `kubectl get pods -A`
4. `kubectl get deployment`
5. `kubectl get svc`
6. Nginx Welcome page through the Load Balancer

---

# 🧹 Cleanup

After completing the testing, Kubernetes resources should be removed before destroying the infrastructure.

Delete the LoadBalancer service first:

```bash
kubectl delete service nginx-service
```

Then delete the Nginx deployment:

```bash
kubectl delete deployment nginx
```

Finally, destroy the Terraform infrastructure:

```bash
terraform destroy
```

This removes the AWS infrastructure created for the project and helps avoid unnecessary AWS charges.

---

# 📚 Key Takeaway

> **Infrastructure as Code makes provisioning easier, but understanding the infrastructure is what makes troubleshooting possible.**

Day 66 completed successfully. 🚀

#DevOps #AWS #EKS #Terraform #Kubernetes #InfrastructureAsCode #90DaysOfDevOps #CloudComputing #LearningInPublic