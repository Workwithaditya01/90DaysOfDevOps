# Day 52 – Kubernetes Namespaces and Deployments

## Overview

Today I learned about **Kubernetes Namespaces and Deployments**.

In the previous session, I worked with standalone Pods. A standalone Pod does not automatically recreate itself if it is deleted. Kubernetes Deployments solve this problem by continuously maintaining the desired number of Pods.

Namespaces help organize and isolate Kubernetes resources inside the same cluster.

---

## Objectives

By the end of this task, I learned how to:

- Explore Kubernetes default namespaces
- Create and use custom namespaces
- Run Pods inside specific namespaces
- List resources across namespaces
- Create a Kubernetes Deployment
- Understand Deployment replicas
- Understand Deployment status
- Understand ReplicaSets
- Demonstrate self-healing
- Scale a Deployment up and down
- Perform rolling updates
- View rollout history
- Roll back a Deployment
- Clean up Kubernetes resources

---

# Task 1 – Explore Default Namespaces

Kubernetes comes with several built-in namespaces.

To list all namespaces:

```bash
kubectl get namespaces
```

Common namespaces include:

| Namespace | Purpose |
|---|---|
| `default` | Default namespace where resources are created when no namespace is specified |
| `kube-system` | Contains Kubernetes system components |
| `kube-public` | Contains resources that can be publicly accessed |
| `kube-node-lease` | Used for node heartbeat and lease information |

---

## Check Pods in `kube-system`

The `kube-system` namespace contains important Kubernetes components.

```bash
kubectl get pods -n kube-system
```

Depending on the Kubernetes distribution and cluster configuration, the Pods may include components such as:

- CoreDNS
- kube-proxy
- kube-apiserver
- kube-controller-manager
- kube-scheduler
- etcd

The exact number of Pods depends on the cluster configuration.

To count the Pods:

```bash
kubectl get pods -n kube-system --no-headers | wc -l
```

> **Important:** The `kube-system` namespace contains critical Kubernetes components. These resources should not be modified or deleted during this exercise.

---

# Task 2 – Create and Use Custom Namespaces

Namespaces can be used to logically separate different environments.

For example:

```text
Kubernetes Cluster
│
├── dev
│   ├── frontend
│   ├── backend
│   └── database
│
├── staging
│   ├── frontend
│   ├── backend
│   └── database
│
└── production
    ├── frontend
    ├── backend
    └── database
```

---

## Create Development and Staging Namespaces

Create the `dev` namespace:

```bash
kubectl create namespace dev
```

Create the `staging` namespace:

```bash
kubectl create namespace staging
```

Verify the namespaces:

```bash
kubectl get namespaces
```

The output should contain the newly created namespaces:

```text
NAME              STATUS
default           Active
dev               Active
kube-node-lease   Active
kube-public       Active
kube-system       Active
staging           Active
```

---

## Create a Namespace Using a Manifest

Namespaces can also be created declaratively using YAML.

### Namespace Manifest

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

Apply the manifest:

```bash
kubectl apply -f namespace.yaml
```

Verify:

```bash
kubectl get namespaces
```

---

## Run a Pod in the `dev` Namespace

Create an Nginx Pod in the development namespace:

```bash
kubectl run nginx-dev --image=nginx:latest -n dev
```

Check the Pod:

```bash
kubectl get pods -n dev
```

---

## Run a Pod in the `staging` Namespace

Create another Nginx Pod in the staging namespace:

```bash
kubectl run nginx-staging --image=nginx:latest -n staging
```

Check the Pod:

```bash
kubectl get pods -n staging
```

---

## List Pods Across All Namespaces

To list Pods from all namespaces:

```bash
kubectl get pods -A
```

The `-A` option means `--all-namespaces`.

---

## Important Namespace Difference

Running:

```bash
kubectl get pods
```

only displays Pods from the `default` namespace.

Running:

```bash
kubectl get pods -n dev
```

displays Pods from the `dev` namespace.

Running:

```bash
kubectl get pods -n staging
```

displays Pods from the `staging` namespace.

Running:

```bash
kubectl get pods -A
```

displays Pods from all namespaces.

### Summary

```text
kubectl get pods
        │
        └── default namespace

kubectl get pods -n dev
        │
        └── dev namespace

kubectl get pods -n staging
        │
        └── staging namespace

kubectl get pods -A
        │
        └── all namespaces
```

---

# Task 3 – Create Your First Deployment

A Kubernetes Deployment manages Pods and ensures that the desired number of replicas are running.

If a Pod fails or is deleted, the Deployment automatically creates a replacement Pod.

---

## Deployment Manifest

Create a Deployment using the following configuration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
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
          image: nginx:1.24
          ports:
            - containerPort: 80
```

---

## Apply the Deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

Check the Deployment:

```bash
kubectl get deployments -n dev
```

Check the Pods:

```bash
kubectl get pods -n dev
```

Because the Deployment specifies:

```yaml
replicas: 3
```

Kubernetes should create three Pods.

---

# Deployment Manifest Explanation

## `apiVersion`

```yaml
apiVersion: apps/v1
```

Specifies the Kubernetes API version used by the Deployment.

Deployments use the `apps/v1` API.

---

## `kind`

```yaml
kind: Deployment
```

Specifies that the Kubernetes resource is a Deployment.

---

## `metadata`

```yaml
metadata:
  name: nginx-deployment
  namespace: dev
```

Defines:

- The name of the Deployment
- The namespace where the Deployment will be created

---

## `labels`

```yaml
labels:
  app: nginx
```

Labels are key-value pairs used to identify and organize Kubernetes resources.

---

## `replicas`

```yaml
replicas: 3
```

Specifies that Kubernetes should maintain three replicas of the application.

If one Pod is deleted, Kubernetes creates another Pod to maintain the desired count.

---

## `selector`

```yaml
selector:
  matchLabels:
    app: nginx
```

The selector tells the Deployment which Pods it manages.

The selector must match the labels defined in the Pod template.

---

## `template`

```yaml
template:
  metadata:
    labels:
      app: nginx
```

The Pod template defines how Pods created by the Deployment should look.

---

## Container Configuration

```yaml
containers:
  - name: nginx
    image: nginx:1.24
```

Defines:

- Container name: `nginx`
- Container image: `nginx:1.24`

The Deployment uses this configuration to create its Pods.

---

## Container Port

```yaml
ports:
  - containerPort: 80
```

Specifies that the Nginx container listens on port `80`.

---

# Understanding Deployment Status

Run:

```bash
kubectl get deployments -n dev
```

Example output:

```text
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3            1m
```

---

## READY

```text
3/3
```

Means three Pods are ready out of the three desired replicas.

---

## UP-TO-DATE

```text
3
```

Means all three Pods are running the latest Deployment configuration.

---

## AVAILABLE

```text
3
```

Means three Pods are currently available.

---

## Healthy Deployment

A healthy Deployment with three replicas will generally look like:

```text
READY        UP-TO-DATE        AVAILABLE
3/3               3                 3
```

---

# Deployment Architecture

A Deployment does not directly manage Pods by itself.

The relationship is:

```text
Deployment
     │
     ▼
ReplicaSet
     │
     ├──────────┬──────────┐
     ▼          ▼          ▼
    Pod        Pod        Pod
     │          │          │
  Nginx      Nginx      Nginx
```

The Deployment manages a ReplicaSet, and the ReplicaSet maintains the desired number of Pods.

You can view the ReplicaSet using:

```bash
kubectl get replicasets -n dev
```

---

# Task 4 – Self-Healing

One of the most important features of a Deployment is **self-healing**.

First, list the Pods:

```bash
kubectl get pods -n dev
```

You should see three Pods.

Example:

```text
NAME                                READY   STATUS
nginx-deployment-abc123-xxxxx       1/1     Running
nginx-deployment-abc123-yyyyy       1/1     Running
nginx-deployment-abc123-zzzzz       1/1     Running
```

---

## Delete One Pod

Choose one Pod and delete it:

```bash
kubectl delete pod <pod-name> -n dev
```

Immediately check the Pods again:

```bash
kubectl get pods -n dev
```

Kubernetes automatically creates a replacement Pod.

---

## Why Does This Happen?

The Deployment wants:

```text
Desired replicas = 3
```

After deleting one Pod:

```text
Current replicas = 2
```

The ReplicaSet detects that the current state does not match the desired state.

It creates another Pod:

```text
Desired replicas = 3
Current replicas = 2

        ↓

ReplicaSet creates new Pod

        ↓

Desired replicas = 3
Current replicas = 3
```

---

## Is the Replacement Pod Name the Same?

No.

The replacement Pod will have a **different name**.

The deleted Pod is permanently removed, and Kubernetes creates a new Pod based on the Deployment's Pod template.

---

# Standalone Pod vs Deployment

## Standalone Pod

```text
Standalone Pod
      │
      ▼
   Deleted
      │
      ▼
   Gone
```

A standalone Pod does not automatically recreate itself after deletion.

---

## Deployment-Managed Pod

```text
Deployment
     │
     ▼
ReplicaSet
     │
     ▼
    Pod
     │
     ▼
  Deleted
     │
     ▼
ReplicaSet detects missing Pod
     │
     ▼
New Pod created
```

This makes Deployments much more reliable for running applications.

---

# Task 5 – Scale the Deployment

Deployments make it easy to increase or decrease the number of application replicas.

Initially:

```yaml
replicas: 3
```

---

## Scale Up to 5 Replicas

Run:

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n dev
```

Check the Deployment:

```bash
kubectl get deployments -n dev
```

Check the Pods:

```bash
kubectl get pods -n dev
```

Kubernetes creates additional Pods until five replicas are running.

---

## Scale Down to 2 Replicas

Run:

```bash
kubectl scale deployment nginx-deployment --replicas=2 -n dev
```

Check:

```bash
kubectl get pods -n dev
```

Kubernetes terminates the extra Pods until only two replicas remain.

For example:

```text
Before:

Pod 1
Pod 2
Pod 3
Pod 4
Pod 5

        ↓ Scale down to 2

After:

Pod 1
Pod 2
```

The extra Pods are terminated because they are no longer required.

---

# Imperative Scaling

Imperative scaling directly tells Kubernetes what action to perform.

Example:

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n dev
```

This immediately changes the number of desired replicas.

---

# Declarative Scaling

Declarative scaling defines the desired state inside the YAML manifest.

For example:

```yaml
spec:
  replicas: 5
```

Then apply the manifest:

```bash
kubectl apply -f nginx-deployment.yaml
```

Kubernetes compares the current state with the desired state and makes the necessary changes.

---

## Imperative vs Declarative

| Method | Example | Description |
|---|---|---|
| Imperative | `kubectl scale ...` | Directly tells Kubernetes what action to perform |
| Declarative | Modify `replicas` in YAML | Defines the desired state and applies it |

Declarative configuration is commonly preferred for real-world Kubernetes environments because configuration can be stored and version-controlled as code.

---

# Task 6 – Rolling Update

Deployments support **rolling updates**.

The original Deployment uses:

```yaml
image: nginx:1.24
```

Update the image to `nginx:1.25`:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
```

Check the rollout:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

---

## How Rolling Updates Work

Before the update:

```text
Pod 1 → nginx:1.24
Pod 2 → nginx:1.24
Pod 3 → nginx:1.24
```

During the update, Kubernetes gradually replaces old Pods:

```text
Pod 1 → nginx:1.25
Pod 2 → nginx:1.24
Pod 3 → nginx:1.24
```

Then:

```text
Pod 1 → nginx:1.25
Pod 2 → nginx:1.25
Pod 3 → nginx:1.24
```

Finally:

```text
Pod 1 → nginx:1.25
Pod 2 → nginx:1.25
Pod 3 → nginx:1.25
```

Kubernetes replaces the Pods gradually according to the Deployment's rolling update strategy.

This controlled replacement helps maintain application availability during updates.

---

## Watch the Rollout

To monitor the rollout:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

You can also watch the Pods:

```bash
kubectl get pods -n dev -w
```

---

# Rollout History

Kubernetes keeps track of Deployment revisions.

View the rollout history:

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

Example:

```text
REVISION
1
2
```

The revisions represent different versions of the Deployment configuration.

---

# Rollback

If the new version causes a problem, the Deployment can be rolled back.

Run:

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

Check the rollout:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

---

## Verify the Image Version

Run:

```bash
kubectl describe deployment nginx-deployment -n dev | grep Image
```

After rolling back from:

```text
nginx:1.25
```

the Deployment should return to the previous version:

```text
nginx:1.24
```

---

# Rolling Update and Rollback Flow

```text
nginx:1.24
     │
     │ Rolling Update
     ▼
nginx:1.25
     │
     │ Problem detected
     ▼
   Rollback
     │
     ▼
nginx:1.24
```

---

# Task 7 – Clean Up

After completing all exercises, clean up the resources.

Delete the Deployment:

```bash
kubectl delete deployment nginx-deployment -n dev
```

Delete the standalone development Pod:

```bash
kubectl delete pod nginx-dev -n dev
```

Delete the standalone staging Pod:

```bash
kubectl delete pod nginx-staging -n staging
```

Delete the custom namespaces:

```bash
kubectl delete namespace dev staging production
```

---

## Verify Cleanup

Check the namespaces:

```bash
kubectl get namespaces
```

Check all Pods:

```bash
kubectl get pods -A
```

Deleting a namespace also deletes all resources inside that namespace.

> **Warning:** Namespace deletion should be performed carefully, especially in production environments.

---

# Important Kubernetes Commands

| Command | Purpose |
|---|---|
| `kubectl get namespaces` | List all namespaces |
| `kubectl create namespace NAME` | Create a namespace |
| `kubectl get pods` | List Pods in the default namespace |
| `kubectl get pods -n NAME` | List Pods in a specific namespace |
| `kubectl get pods -A` | List Pods across all namespaces |
| `kubectl apply -f FILE.yaml` | Create or update resources from a manifest |
| `kubectl get deployments -n NAME` | List Deployments |
| `kubectl get replicasets -n NAME` | List ReplicaSets |
| `kubectl delete pod NAME -n NAME` | Delete a Pod |
| `kubectl scale deployment NAME --replicas=N -n NAME` | Scale a Deployment |
| `kubectl set image deployment/NAME ...` | Update a Deployment image |
| `kubectl rollout status deployment/NAME -n NAME` | Check rollout status |
| `kubectl rollout history deployment/NAME -n NAME` | View Deployment history |
| `kubectl rollout undo deployment/NAME -n NAME` | Roll back a Deployment |
| `kubectl describe deployment NAME -n NAME` | Display Deployment details |
| `kubectl delete deployment NAME -n NAME` | Delete a Deployment |
| `kubectl delete namespace NAME` | Delete a namespace |

---

# Key Learnings

Today I learned that:

1. **Namespaces** provide logical separation of Kubernetes resources.
2. Kubernetes has built-in namespaces such as `default`, `kube-system`, `kube-public`, and `kube-node-lease`.
3. Resources can be targeted using `-n <namespace>`.
4. `kubectl get pods -A` displays Pods across all namespaces.
5. A **Deployment** manages application Pods.
6. Deployments use **ReplicaSets** to maintain the desired number of Pods.
7. Deployments provide **self-healing** when Pods are deleted or fail.
8. Deployments can be scaled up and down.
9. Scaling can be performed using imperative or declarative methods.
10. Deployments support **rolling updates**.
11. Kubernetes maintains Deployment revision history.
12. Deployments can be rolled back to a previous revision.
13. Deleting a namespace removes the resources inside that namespace.

---

# Kubernetes Deployment Architecture

```text
                         Kubernetes Cluster
                                │
              ┌─────────────────┴─────────────────┐
              │                                   │
             dev                              staging
              │                                   │
       nginx Deployment                     nginx Pod
              │
              ▼
         ReplicaSet
              │
       ┌──────┼──────┐
       │      │      │
       ▼      ▼      ▼
      Pod    Pod    Pod
       │      │      │
       ▼      ▼      ▼
     nginx  nginx  nginx
```

---

# Complete Day 52 Flow

```text
Namespace
    │
    ▼
Deployment
    │
    ▼
ReplicaSet
    │
    ▼
Multiple Pods
    │
    ▼
Containers
```

The Deployment continuously works toward the desired state.

For example:

```text
Desired State:
replicas = 3

        │
        ▼

Deployment
        │
        ▼

ReplicaSet
        │
        ▼

3 Running Pods
```

If one Pod is deleted:

```text
3 Pods
  │
  ▼
1 Pod Deleted
  │
  ▼
2 Pods Remaining
  │
  ▼
ReplicaSet Detects Difference
  │
  ▼
New Pod Created
  │
  ▼
3 Pods Running Again
```

---

# Day 52 Summary

Day 52 introduced two important Kubernetes concepts: **Namespaces and Deployments**.

Namespaces provide logical separation and organization of Kubernetes resources. They can be used to separate environments such as development, staging, and production.

Deployments provide a reliable way to run applications with multiple replicas. Unlike standalone Pods, Deployment-managed Pods are automatically recreated if they are deleted or fail.

I also learned how to:

- Create and manage namespaces
- Run Pods in specific namespaces
- Create Deployments
- Manage multiple replicas
- Understand ReplicaSets
- Demonstrate self-healing
- Scale applications
- Perform rolling updates
- View rollout history
- Roll back deployments

The main Kubernetes workload relationship learned today is:

```text
Namespace
    ↓
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Containers
```

This is an important step toward understanding how Kubernetes manages applications in real-world DevOps environments.

---

## Day 52 – What I Practiced

```text
Namespaces
     ↓
Resource Isolation
     ↓
Deployments
     ↓
ReplicaSets
     ↓
Self-Healing
     ↓
Scaling
     ↓
Rolling Updates
     ↓
Rollback
```

**Day 52 completed – Kubernetes Namespaces and Deployments.**
