# Day 51 – Kubernetes Manifests and Your First Pods

## 📌 Objective

Today's goal was to understand the anatomy of a Kubernetes Manifest and deploy Pods using YAML files. I learned how to write Pod manifests from scratch, validate them, inspect running Pods, and understand the difference between imperative and declarative approaches.

---

# What is a Kubernetes Manifest?

A Kubernetes Manifest is a YAML file that defines the desired state of a Kubernetes resource.

Every manifest contains four required top-level fields.

| Field | Purpose |
|--------|---------|
| `apiVersion` | Specifies which Kubernetes API version should be used. |
| `kind` | Defines the type of Kubernetes resource (Pod, Deployment, Service, etc.). |
| `metadata` | Contains information such as the resource name and labels. |
| `spec` | Describes the desired state of the resource, including containers, images, ports, and other configurations. |

---

# Task 1 – Create an Nginx Pod

## nginx-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

## Commands Used

```bash
kubectl apply -f nginx-pod.yaml

kubectl get pods

kubectl get pods -o wide

kubectl describe pod nginx-pod

kubectl logs nginx-pod

kubectl exec -it nginx-pod -- /bin/bash
```

If Bash is unavailable:

```bash
kubectl exec -it nginx-pod -- /bin/sh
```

Inside the container:

```bash
curl localhost:80
```

### Result

The Pod entered the **Running** state successfully, and the Nginx Welcome Page was displayed when accessing `localhost:80` from inside the container.

---

# Task 2 – Create a BusyBox Pod

## busybox-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
    - name: busybox
      image: busybox:latest
      command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

## Commands Used

```bash
kubectl apply -f busybox-pod.yaml

kubectl get pods

kubectl logs busybox-pod
```

### Result

The logs displayed:

```text
Hello from BusyBox
```

### Why is the command field required?

BusyBox does not run a long-lived process by default. Without specifying a command that keeps the container alive (such as `sleep 3600`), the container exits immediately, causing the Pod to terminate or restart repeatedly.

---

# Task 3 – Create a Third Pod

## apache-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache-pod
  labels:
    app: apache
    environment: testing
    team: devops
spec:
  containers:
    - name: apache
      image: httpd:latest
      ports:
        - containerPort: 80
```

## Commands Used

```bash
kubectl apply -f apache-pod.yaml

kubectl get pods

kubectl get pods --show-labels
```

---

# Task 4 – Imperative vs Declarative

## Imperative Approach

Create a Pod directly from the command line.

```bash
kubectl run redis-pod --image=redis:latest
```

View the generated YAML.

```bash
kubectl get pod redis-pod -o yaml
```

Generate a manifest without creating the resource.

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml > test-pod.yaml
```

---

## Declarative Approach

Create resources from YAML files.

```bash
kubectl apply -f nginx-pod.yaml
```

### Comparison

| Imperative | Declarative |
|------------|-------------|
| Uses CLI commands | Uses YAML files |
| Quick for testing | Best for production |
| Difficult to track changes | Easy to version control with Git |
| Less reusable | Highly reusable |

---

# Task 5 – Validate Before Applying

Client-side validation:

```bash
kubectl apply -f nginx-pod.yaml --dry-run=client
```

Server-side validation:

```bash
kubectl apply -f nginx-pod.yaml --dry-run=server
```

### Error When Image Field is Removed

If the `image` field is removed from the manifest, Kubernetes returns an error similar to:

```text
The Pod "nginx-pod" is invalid:
spec.containers[0].image: Required value
```

---

# Task 6 – Working with Labels

View all Pod labels.

```bash
kubectl get pods --show-labels
```

Filter Pods using labels.

```bash
kubectl get pods -l app=nginx

kubectl get pods -l environment=dev

kubectl get pods -l team=devops
```

Add a new label.

```bash
kubectl label pod nginx-pod environment=production
```

Remove the label.

```bash
kubectl label pod nginx-pod environment-
```

---

# Cleanup

Delete individual Pods.

```bash
kubectl delete pod nginx-pod

kubectl delete pod busybox-pod

kubectl delete pod redis-pod

kubectl delete pod apache-pod
```

Or delete using YAML files.

```bash
kubectl delete -f nginx-pod.yaml

kubectl delete -f busybox-pod.yaml

kubectl delete -f apache-pod.yaml
```

Verify all Pods have been removed.

```bash
kubectl get pods
```

---

# Standalone Pod vs Deployment

A standalone Pod is **not managed by any controller**. Once it is deleted, Kubernetes does not recreate it.

Deployments manage Pods automatically. If a Pod fails or is deleted, the Deployment creates a new Pod to maintain the desired number of replicas.

---

# Key Learnings

- Learned the structure of a Kubernetes Manifest.
- Created multiple Pod manifests from scratch.
- Deployed Pods using declarative YAML files.
- Used `kubectl describe`, `logs`, and `exec` for inspection and troubleshooting.
- Learned the difference between imperative and declarative resource creation.
- Used labels to organize and filter Kubernetes resources.
- Validated manifests using dry-run before deployment.
- Understood why standalone Pods are not suitable for production environments.

---

# Screenshot

> **Add your screenshot here**

```
kubectl get pods
```

Example:

```text
NAME           READY   STATUS    RESTARTS   AGE
nginx-pod      1/1     Running   0          2m
busybox-pod    1/1     Running   0          1m
apache-pod     1/1     Running   0          30s
redis-pod      1/1     Running   0          20s
```

---

# Conclusion

Today I learned how Kubernetes Pods are defined using YAML manifests. I created multiple Pods, explored them using various `kubectl` commands, worked with labels, validated manifests before deployment, and understood why Deployments are preferred over standalone Pods in production environments.

This session built a strong foundation for learning Kubernetes Deployments in the next phase of the journey.
