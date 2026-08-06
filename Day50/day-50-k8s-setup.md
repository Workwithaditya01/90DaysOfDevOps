# Day 50 – Kubernetes Architecture and Cluster Setup

## 📌 Objective

Today marks the beginning of my Kubernetes journey. After learning Docker and containerization, I explored why Kubernetes was created, understood its architecture, created a local Kubernetes cluster, and practiced basic `kubectl` commands.

---

# Task 1 – Kubernetes Story

## Why was Kubernetes created?

Docker made it easy to package and run applications inside containers, but managing hundreds or thousands of containers across multiple servers became extremely difficult.

Kubernetes solves this problem by automating:

- Container deployment
- Scaling
- Load balancing
- Service discovery
- Self-healing
- Rolling updates
- High availability

Instead of manually managing containers, Kubernetes automatically maintains the desired state of applications.

---

## Who created Kubernetes?

Kubernetes was originally developed by **Google** and later donated to the **Cloud Native Computing Foundation (CNCF)**.

It was inspired by Google's internal container orchestration system called **Borg**, which Google had used for many years to manage millions of containers.

---

## What does Kubernetes mean?

The word **Kubernetes** comes from Greek and means:

> **"Helmsman" or "Pilot"**

which perfectly represents steering and managing containerized applications.

Its abbreviation **K8s** comes from replacing the eight letters between **K** and **s**.

---

# Task 2 – Kubernetes Architecture

```
                    Kubernetes Cluster

                +-------------------------+
                |      Control Plane      |
                +-------------------------+

                 +-------------------+
                 |    API Server      |
                 +-------------------+
                           |
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

## Components Explained

### API Server

- Entry point of Kubernetes
- Receives every request from kubectl
- Validates requests
- Stores cluster information in etcd

---

### etcd

- Distributed key-value database
- Stores complete cluster state
- Source of truth for Kubernetes

---

### Scheduler

Responsible for selecting the best worker node for newly created Pods based on:

- Available CPU
- Available Memory
- Affinity rules
- Taints and tolerations
- Resource requirements

---

### Controller Manager

Runs various controllers that continuously compare the desired state with the actual state.

Examples:

- Node Controller
- ReplicaSet Controller
- Deployment Controller
- Job Controller

---

### kubelet

Runs on every worker node.

Responsibilities:

- Communicates with API Server
- Starts Pods
- Monitors Pods
- Reports node health

---

### kube-proxy

Responsible for networking.

It manages:

- Service networking
- Pod communication
- Load balancing

---

### Container Runtime

Actually runs containers.

Examples:

- containerd
- CRI-O

---

# What happens when I run:

```bash
kubectl apply -f pod.yaml
```

Step-by-step flow:

1. kubectl sends the YAML to API Server.
2. API Server validates the request.
3. API Server stores desired state inside etcd.
4. Scheduler selects the best worker node.
5. kubelet receives instructions.
6. Container Runtime downloads the image.
7. Pod starts running.
8. kube-proxy updates networking rules.
9. Status is reported back to API Server.

---

## What happens if API Server goes down?

- kubectl cannot communicate with the cluster.
- No new Pods can be created.
- Existing running Pods continue running.
- Cluster management operations stop until API Server is restored.

---

## What happens if a Worker Node goes down?

- Node becomes **NotReady**.
- Controller Manager detects the failure.
- Pods on that node are recreated on another healthy worker node (if available).
- This provides self-healing.

---

# Task 3 – Install kubectl

## Windows

```powershell
choco install kubernetes-cli
```

Verify installation:

```bash
kubectl version --client
```

Example Output:

```text
Client Version: v1.xx.x
Kustomize Version: v5.x.x
```

---

# Task 4 – Local Cluster Setup

## Selected Tool

✅ **kind (Kubernetes IN Docker)**

### Why kind?

- Lightweight
- Fast startup
- Uses Docker containers
- Perfect for local development
- Easy to create and delete clusters

---

## Create Cluster

```bash
kind create cluster --name devops-cluster
```

Verify:

```bash
kubectl cluster-info

kubectl get nodes
```

Example Output

```text
NAME                     STATUS   ROLES           AGE   VERSION
devops-cluster-control-plane   Ready   control-plane   1m    v1.xx.x
```

---

# Task 5 – Explore the Cluster

## Cluster Information

```bash
kubectl cluster-info
```

---

## List Nodes

```bash
kubectl get nodes
```

---

## Describe Node

```bash
kubectl describe node devops-cluster-control-plane
```

---

## Namespaces

```bash
kubectl get namespaces
```

Example:

```
default
kube-system
kube-public
kube-node-lease
```

---

## All Pods

```bash
kubectl get pods -A
```

---

## kube-system Pods

```bash
kubectl get pods -n kube-system
```

Typical Output:

```
coredns
etcd
kindnet
kube-apiserver
kube-controller-manager
kube-proxy
kube-scheduler
```

---

# What each kube-system Pod does

| Pod | Purpose |
|------|---------|
| kube-apiserver | Entry point of Kubernetes API |
| etcd | Stores cluster state |
| kube-controller-manager | Maintains desired state |
| kube-scheduler | Assigns Pods to nodes |
| kube-proxy | Handles networking |
| coredns | DNS service inside cluster |
| kindnet | Network plugin for kind |

---

# Task 6 – Cluster Lifecycle

Delete cluster:

```bash
kind delete cluster --name devops-cluster
```

Create cluster again:

```bash
kind create cluster --name devops-cluster
```

Verify:

```bash
kubectl get nodes
```

Useful commands:

Current context:

```bash
kubectl config current-context
```

List contexts:

```bash
kubectl config get-contexts
```

View kubeconfig:

```bash
kubectl config view
```

---

## What is kubeconfig?

A kubeconfig file stores cluster connection information.

It contains:

- Cluster details
- User credentials
- Contexts
- Authentication data

kubectl reads this file to know which Kubernetes cluster to communicate with.

Default location:

### Linux/macOS

```text
~/.kube/config
```

### Windows

```text
C:\Users\<username>\.kube\config
```

---

# Key Learnings

- Learned why Kubernetes was created.
- Understood Control Plane and Worker Node architecture.
- Explored API Server, Scheduler, etcd, Controller Manager, kubelet, kube-proxy, and Container Runtime.
- Created a local Kubernetes cluster using kind.
- Practiced essential kubectl commands.
- Explored namespaces and system Pods.
- Learned how Kubernetes stores configuration using kubeconfig.
- Understood the complete Pod creation workflow.

---

# Conclusion

Day 50 introduced me to the core architecture of Kubernetes and how a cluster operates internally. Setting up a local cluster with kind and exploring the control plane components running as Pods gave me a practical understanding of container orchestration. This marks the beginning of my Kubernetes journey and builds the foundation for deploying, scaling, and managing applications in future DevOps projects.

---


