# Day 50 – Kubernetes Architecture and Cluster Setup ☸️

## 📖 Overview

Welcome to **Day 50** of my **#90DaysOfDevOps** journey!

Today marks the beginning of my Kubernetes learning path. After understanding Docker and containerization, I explored why Kubernetes was created, learned its architecture, set up a local Kubernetes cluster using **Kind**, and practiced essential `kubectl` commands.

---

## 🎯 Objectives

- Understand why Kubernetes was created.
- Learn Kubernetes architecture.
- Install and configure `kubectl`.
- Create a local Kubernetes cluster.
- Explore Kubernetes system components.
- Learn cluster lifecycle operations.
- Understand how `kubectl` communicates with the cluster.

---

# 📚 What I Learned

## Why Kubernetes?

Docker makes it easy to package applications into containers, but managing hundreds or thousands of containers across multiple servers becomes difficult.

Kubernetes solves this problem by providing:

- Automated deployment
- Scaling
- Load Balancing
- Service Discovery
- Self-Healing
- Rolling Updates
- High Availability

---

## History of Kubernetes

- Developed by **Google**
- Inspired by Google's internal system **Borg**
- Donated to the **Cloud Native Computing Foundation (CNCF)**
- Kubernetes (K8s) means **"Helmsman" or "Pilot"** in Greek.

---

# Kubernetes Architecture

```text
                    Kubernetes Cluster

                +-------------------------+
                |      Control Plane      |
                +-------------------------+

                 +-------------------+
                 |    API Server      |
                 +-------------------+
                           |
                 +-------------------+
                 |       etcd        |
                 +-------------------+

                 +-------------------+
                 |    Scheduler      |
                 +-------------------+

                 +-------------------+
                 | Controller Manager|
                 +-------------------+

------------------------------------------------------------

                +-------------------------+
                |      Worker Node        |
                +-------------------------+

                  +----------------+
                  |    kubelet     |
                  +----------------+

                  +----------------+
                  |  kube-proxy    |
                  +----------------+

                  +----------------+
                  |Container Runtime|
                  | (containerd)   |
                  +----------------+

                        |
                    +--------+
                    |  Pods  |
                    +--------+
```

---

# Control Plane Components

## API Server

- Entry point of Kubernetes.
- Receives requests from `kubectl`.
- Validates API requests.
- Stores cluster state in etcd.

---

## etcd

- Distributed key-value database.
- Stores the complete cluster state.
- Source of truth for Kubernetes.

---

## Scheduler

Responsible for selecting the best worker node for newly created Pods.

---

## Controller Manager

Ensures the actual state matches the desired state.

Handles:

- ReplicaSets
- Deployments
- Jobs
- Nodes

---

# Worker Node Components

## kubelet

- Node agent.
- Creates Pods.
- Reports node health.
- Communicates with API Server.

---

## kube-proxy

Responsible for:

- Pod networking
- Service networking
- Load balancing.

---

## Container Runtime

Runs containers inside Pods.

Examples:

- containerd
- CRI-O

---

# Pod Creation Workflow

When executing:

```bash
kubectl apply -f pod.yaml
```

The workflow is:

1. kubectl sends the request to the API Server.
2. API Server validates the request.
3. Desired state is stored in etcd.
4. Scheduler selects the best worker node.
5. kubelet creates the Pod.
6. Container Runtime downloads the image.
7. kube-proxy configures networking.
8. Pod starts running.

---

# Local Kubernetes Cluster

## Tool Used

**Kind (Kubernetes IN Docker)**

### Why Kind?

- Lightweight
- Fast
- Docker-based
- Easy to create and delete clusters.
- Ideal for local Kubernetes practice.

---

# Commands Practiced

## Create Cluster

```bash
kind create cluster --name tws-cluster
```

## Cluster Information

```bash
kubectl cluster-info
```

## List Nodes

```bash
kubectl get nodes
```

## Describe Node

```bash
kubectl describe node <node-name>
```

## List Namespaces

```bash
kubectl get namespaces
```

## List All Pods

```bash
kubectl get pods -A
```

## View kube-system Pods

```bash
kubectl get pods -n kube-system
```

---

# Cluster Lifecycle

## Delete Cluster

```bash
kind delete cluster --name tws-cluster
```

## Recreate Cluster

```bash
kind create cluster --name tws-cluster
```

---

# kubeconfig Commands

### Current Context

```bash
kubectl config current-context
```

### Available Contexts

```bash
kubectl config get-contexts
```

### View kubeconfig

```bash
kubectl config view
```

---

# kube-system Components

| Component | Purpose |
|-----------|---------|
| kube-apiserver | Entry point of the Kubernetes API |
| etcd | Stores cluster state |
| kube-scheduler | Assigns Pods to nodes |
| kube-controller-manager | Maintains the desired state |
| kube-proxy | Handles networking |
| CoreDNS | Provides DNS inside the cluster |
| kindnet | Networking plugin used by Kind |

---

# Key Takeaways

- Learned why Kubernetes was created.
- Explored Kubernetes architecture.
- Understood the responsibilities of the Control Plane and Worker Nodes.
- Installed and configured `kubectl`.
- Created a local Kubernetes cluster using Kind.
- Practiced essential Kubernetes commands.
- Explored namespaces and system Pods.
- Learned how `kubeconfig` manages cluster connections.
- Understood the complete Pod creation workflow.

---

# Conclusion

Day 50 marked the beginning of my Kubernetes journey. I explored the architecture, understood how the Control Plane and Worker Nodes work together, created a local Kubernetes cluster using Kind, and practiced essential `kubectl` commands. This foundational knowledge will help me deploy, scale, and manage containerized applications more effectively as I continue my DevOps journey.

---

## 🤝 Connect With Me

- **GitHub:** https://github.com/Workwithaditya01
- **LinkedIn:** https://www.linkedin.com/in/adityasondekar/

---

⭐ If you found this repository helpful, consider giving it a **Star** and follow my **#90DaysOfDevOps** journey!
