# Day 53 – Kubernetes Services

## 📌 Task

Today I learned about **Kubernetes Services** and how they provide a stable network endpoint for Pods.

Pods are temporary and their IP addresses can change whenever they are restarted or replaced. A Service solves this problem by providing:

- A stable IP address
- A stable DNS name
- Load balancing across multiple Pods
- A consistent way to access applications

### Service Types Covered

- **ClusterIP** – Internal communication inside the cluster
- **NodePort** – External access through a Kubernetes node
- **LoadBalancer** – External access through a cloud load balancer

---

# 📂 Project Structure

```text
2026/
└── day-53/
    ├── app-deployment.yaml
    ├── clusterip-service.yaml
    ├── nodeport-service.yaml
    ├── loadbalancer-service.yaml
    └── day-53-services.md
```

---

# 🏗️ Architecture

```text
                         Kubernetes Cluster
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    Deployment                           │
│                        │                                │
│             ┌──────────┼──────────┐                     │
│             │          │          │                     │
│             ▼          ▼          ▼                     │
│           Pod 1      Pod 2      Pod 3                   │
│             │          │          │                     │
│             └──────────┼──────────┘                     │
│                        │                                │
│                  ┌─────▼─────┐                          │
│                  │  Service  │                          │
│                  └─────┬─────┘                          │
│                        │                                │
│          ┌─────────────┼──────────────┐                 │
│          │             │              │                 │
│          ▼             ▼              ▼                 │
│      ClusterIP      NodePort      LoadBalancer          │
│          │             │              │                 │
│       Internal      Node Access    Cloud Access         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

# Why Do We Need Services?

Every Pod gets its own IP address, but Pod IP addresses are **not stable**.

When a Pod is deleted or recreated, Kubernetes may assign it a new IP address.

A Deployment can also run multiple replicas:

```text
                    Deployment
                        |
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
        Pod 1         Pod 2         Pod 3
      10.244.x.x    10.244.x.x    10.244.x.x
```

Instead of connecting directly to individual Pod IPs, clients communicate with a Service:

```text
Client
  |
  v
Service
  |
  +----> Pod 1
  |
  +----> Pod 2
  |
  +----> Pod 3
```

The Service provides a stable endpoint and distributes traffic between the Pods.

---

# Task 1 – Deploy the Application

Create the file:

```text
app-deployment.yaml
```

## Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

## Apply the Deployment

```bash
kubectl apply -f app-deployment.yaml
```

## Check the Deployment

```bash
kubectl get deployments
```

## Check the Pods

```bash
kubectl get pods
```

## Check Pod IP Addresses

```bash
kubectl get pods -o wide
```

Example:

```text
NAME                        READY   STATUS    IP
web-app-xxxxxxxxxx-xxxxx    1/1     Running   10.244.x.x
web-app-xxxxxxxxxx-yyyyy    1/1     Running   10.244.x.x
web-app-xxxxxxxxxx-zzzzz    1/1     Running   10.244.x.x
```

### Verification

There should be **3 running Pods**.

The Pod IP addresses are temporary and can change when Pods are recreated.

---

# Task 2 – ClusterIP Service

## What is ClusterIP?

**ClusterIP** is the default Kubernetes Service type.

It provides an internal endpoint that can be accessed from within the Kubernetes cluster.

Create:

```text
clusterip-service.yaml
```

## ClusterIP Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
```

## Apply the Service

```bash
kubectl apply -f clusterip-service.yaml
```

## Check Services

```bash
kubectl get services
```

Or:

```bash
kubectl get svc
```

Example:

```text
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
web-app-clusterip    ClusterIP   10.96.x.x       <none>        80/TCP
```

## Important Fields

### Selector

```yaml
selector:
  app: web-app
```

The selector tells the Service which Pods should receive traffic.

The Pod must have the matching label:

```yaml
labels:
  app: web-app
```

### Port

```yaml
port: 80
```

The port exposed by the Service.

### Target Port

```yaml
targetPort: 80
```

The port on the target Pod.

Traffic flow:

```text
Client
  |
  v
Service:80
  |
  +----> Pod:80
  |
  +----> Pod:80
  |
  +----> Pod:80
```

---

# Task 3 – Test ClusterIP Communication

ClusterIP is intended for internal cluster communication.

Run a temporary BusyBox Pod:

```bash
kubectl run test-client \
  --image=busybox:latest \
  --rm -it \
  --restart=Never \
  -- sh
```

Inside the temporary Pod:

```bash
wget -qO- http://web-app-clusterip
```

You should receive the Nginx welcome page HTML.

Exit the temporary Pod:

```bash
exit
```

## Check Service Endpoints

```bash
kubectl get endpoints web-app-clusterip
```

The output should contain the IP addresses of the Pods selected by the Service.

You can also use:

```bash
kubectl describe service web-app-clusterip
```

---

# Task 4 – Kubernetes DNS Service Discovery

Kubernetes automatically creates DNS records for Services.

The general DNS format is:

```text
<service-name>.<namespace>.svc.cluster.local
```

For this Service:

```text
web-app-clusterip.default.svc.cluster.local
```

## Start a DNS Test Pod

```bash
kubectl run dns-test \
  --image=busybox:latest \
  --rm -it \
  --restart=Never \
  -- sh
```

## Test the Short DNS Name

Inside the Pod:

```bash
wget -qO- http://web-app-clusterip
```

## Test the Full DNS Name

```bash
wget -qO- http://web-app-clusterip.default.svc.cluster.local
```

Both should resolve to the same Service.

## Check DNS Resolution

```bash
nslookup web-app-clusterip
```

Check the Service ClusterIP:

```bash
kubectl get service web-app-clusterip
```

The IP returned by `nslookup` should match the Service's `CLUSTER-IP`.

Exit:

```bash
exit
```

---

# Task 5 – NodePort Service

## What is NodePort?

A **NodePort** Service exposes an application on a port on every Kubernetes node.

Traffic flow:

```text
External Client
      |
      v
NodeIP:30080
      |
      v
NodePort Service
      |
      v
ClusterIP
      |
      v
Pod:80
```

Create:

```text
nodeport-service.yaml
```

## NodePort Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

## Apply the Service

```bash
kubectl apply -f nodeport-service.yaml
```

## Check Services

```bash
kubectl get services
```

Example:

```text
NAME                 TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)
web-app-nodeport     NodePort   10.96.x.x       <none>        80:30080/TCP
```

The NodePort range is:

```text
30000-32767
```

In this example:

```text
Service Port = 80
NodePort     = 30080
Target Port  = 80
```

---

# Task 6 – Test NodePort

## If Using Minikube

```bash
minikube service web-app-nodeport --url
```

Use the URL returned by Minikube.

## If Using Kind

Check the nodes:

```bash
kubectl get nodes -o wide
```

Then access:

```text
<NodeIP>:30080
```

> **Note:** With Kind, direct access to a NodePort from the host depends on the cluster configuration. A host port mapping may be required.

## If Using Docker Desktop

Try:

```bash
curl http://localhost:30080
```

If the configuration exposes the NodePort to the host, you should receive the Nginx welcome page.

---

# Task 7 – LoadBalancer Service

## What is LoadBalancer?

A **LoadBalancer** Service is designed to expose an application through an external load balancer.

In cloud environments, Kubernetes can provision a real load balancer through the cloud provider.

Traffic flow:

```text
Internet
   |
   v
Cloud Load Balancer
   |
   v
Kubernetes Service
   |
   v
Pods
```

Create:

```text
loadbalancer-service.yaml
```

## LoadBalancer Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
```

## Apply the Service

```bash
kubectl apply -f loadbalancer-service.yaml
```

## Check the Service

```bash
kubectl get services
```

Example on a local cluster:

```text
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)
web-app-loadbalancer    LoadBalancer   10.96.x.x       <pending>     80:xxxxx/TCP
```

---

# Why is EXTERNAL-IP `<pending>`?

When using a local Kubernetes cluster such as Kind, there is usually no cloud provider available to provision a real external load balancer.

Therefore:

```text
EXTERNAL-IP = <pending>
```

is expected.

In a cloud environment, Kubernetes may provision an external IP address or hostname.

---

# Minikube LoadBalancer

If you are using Minikube, you can simulate LoadBalancer behavior with:

```bash
minikube tunnel
```

Keep the tunnel running in one terminal.

Then, in another terminal:

```bash
kubectl get services
```

---

# Task 8 – Compare All Three Services

Run:

```bash
kubectl get services -o wide
```

You should see the three Services.

Example:

```text
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)
web-app-clusterip       ClusterIP      10.96.x.x       <none>        80/TCP
web-app-nodeport        NodePort       10.96.x.x       <none>        80:30080/TCP
web-app-loadbalancer    LoadBalancer   10.96.x.x       <pending>     80:xxxxx/TCP
```

## Comparison

| Service Type | Accessible From | Main Use Case |
|---|---|---|
| ClusterIP | Inside the cluster | Internal communication |
| NodePort | Outside through Node IP and NodePort | Development and testing |
| LoadBalancer | Outside through external load balancer | Production cloud applications |

---

# ClusterIP

```text
Client inside cluster
        |
        v
    ClusterIP
        |
        v
       Pods
```

Use ClusterIP for:

- Internal APIs
- Backend services
- Databases
- Service-to-service communication

---

# NodePort

```text
External Client
      |
      v
NodeIP:30080
      |
      v
    Service
      |
      v
     Pods
```

Use NodePort for:

- Development
- Testing
- Direct node access
- Learning Kubernetes networking

---

# LoadBalancer

```text
Internet
   |
   v
Cloud Load Balancer
   |
   v
Kubernetes Service
   |
   v
Pods
```

Use LoadBalancer for:

- Public-facing applications
- Production applications
- Cloud environments

---

# Task 9 – Understand the Service Relationship

A LoadBalancer Service normally builds on top of NodePort and ClusterIP.

Conceptually:

```text
LoadBalancer
     |
     v
  NodePort
     |
     v
 ClusterIP
     |
     v
    Pods
```

Inspect the LoadBalancer Service:

```bash
kubectl describe service web-app-loadbalancer
```

Look for:

- ClusterIP
- NodePort
- Endpoints
- Ports
- Selector

The LoadBalancer Service should have a ClusterIP and, under the standard configuration, a NodePort.

---

# Task 10 – Inspect Endpoints

Endpoints represent the Pod addresses currently associated with a Service.

Run:

```bash
kubectl get endpoints web-app-clusterip
```

Example:

```text
NAME                 ENDPOINTS
web-app-clusterip    10.244.1.5:80,10.244.2.7:80,10.244.3.8:80
```

You can also inspect the Service:

```bash
kubectl describe service web-app-clusterip
```

Look for:

```text
Selector:        app=web-app
Endpoints:       10.244.x.x:80,10.244.x.x:80,10.244.x.x:80
```

## Why Are Endpoints Important?

Suppose the Service currently routes to:

```text
Pod 1 → 10.244.1.5
Pod 2 → 10.244.2.7
Pod 3 → 10.244.3.8
```

If Pod 2 is deleted, Kubernetes updates the endpoints.

A replacement Pod may receive a new IP:

```text
Pod 1 → 10.244.1.5
Pod 2 → Deleted
Pod 3 → 10.244.3.8
Pod 4 → 10.244.2.15
```

The Service automatically updates its backend endpoints.

The client continues using the same Service.

---

# Task 11 – Verify Service Selectors

Check Pod labels:

```bash
kubectl get pods --show-labels
```

The Pods should have:

```text
app=web-app
```

Check the Service selector:

```bash
kubectl describe service web-app-clusterip
```

You should see:

```text
Selector: app=web-app
```

## Correct Configuration

```text
Service selector:
app=web-app

Pod label:
app=web-app
```

## Incorrect Configuration

```text
Service selector:
app=frontend

Pod label:
app=web-app
```

If the selector does not match the Pod labels, the Service will not have endpoints.

Check with:

```bash
kubectl get endpoints web-app-clusterip
```

---

# Task 12 – Test Service Communication

Start a temporary test Pod:

```bash
kubectl run test-client \
  --image=busybox:latest \
  --rm -it \
  --restart=Never \
  -- sh
```

Inside the Pod:

```bash
wget -qO- http://web-app-clusterip
```

The request should reach one of the three Nginx Pods.

Exit:

```bash
exit
```

Check the endpoints:

```bash
kubectl get endpoints web-app-clusterip
```

---

# Task 13 – Capture the Screenshot

Run:

```bash
kubectl get services -o wide
```

Take a screenshot showing:

```text
NAME
TYPE
CLUSTER-IP
EXTERNAL-IP
PORT(S)
```

Also capture the ClusterIP communication test:

```bash
wget -qO- http://web-app-clusterip
```

Add the screenshot to the GitHub repository if required by the challenge.

---

# Task 14 – Clean Up

Delete the Deployment:

```bash
kubectl delete -f app-deployment.yaml
```

Delete the ClusterIP Service:

```bash
kubectl delete -f clusterip-service.yaml
```

Delete the NodePort Service:

```bash
kubectl delete -f nodeport-service.yaml
```

Delete the LoadBalancer Service:

```bash
kubectl delete -f loadbalancer-service.yaml
```

## Verify Pods

```bash
kubectl get pods
```

## Verify Services

```bash
kubectl get services
```

Only the built-in `kubernetes` Service in the default namespace should remain.

---

# 🔑 Important Commands

## Deployment

```bash
kubectl apply -f app-deployment.yaml
kubectl get deployments
kubectl get pods
kubectl get pods -o wide
```

## Services

```bash
kubectl apply -f clusterip-service.yaml
kubectl apply -f nodeport-service.yaml
kubectl apply -f loadbalancer-service.yaml
```

## Check Services

```bash
kubectl get services
kubectl get svc
kubectl get services -o wide
```

## Describe a Service

```bash
kubectl describe service <service-name>
```

Example:

```bash
kubectl describe service web-app-clusterip
```

## Check Endpoints

```bash
kubectl get endpoints <service-name>
```

Example:

```bash
kubectl get endpoints web-app-clusterip
```

## Test ClusterIP

```bash
kubectl run test-client \
  --image=busybox:latest \
  --rm -it \
  --restart=Never \
  -- sh
```

Inside:

```bash
wget -qO- http://web-app-clusterip
```

## Test DNS

```bash
nslookup web-app-clusterip
```

## Delete Resources

```bash
kubectl delete -f app-deployment.yaml
kubectl delete -f clusterip-service.yaml
kubectl delete -f nodeport-service.yaml
kubectl delete -f loadbalancer-service.yaml
```

---

# 🧠 Key Concepts Learned

## Pods

Pods run application containers.

Their IP addresses are temporary and can change.

## Deployments

Deployments manage multiple replicas of Pods.

```text
Deployment
    |
    +--- Pod 1
    +--- Pod 2
    +--- Pod 3
```

## Services

Services provide a stable way to communicate with Pods.

```text
Client
  |
  v
Service
  |
  +--- Pod 1
  +--- Pod 2
  +--- Pod 3
```

## Selectors

Services use selectors to identify the Pods that should receive traffic.

```yaml
selector:
  app: web-app
```

The Pods must have:

```yaml
labels:
  app: web-app
```

## DNS

Every Kubernetes Service receives a DNS record.

```text
service.namespace.svc.cluster.local
```

Example:

```text
web-app-clusterip.default.svc.cluster.local
```

## Endpoints

Endpoints contain the addresses of the Pods currently receiving traffic from a Service.

```bash
kubectl get endpoints web-app-clusterip
```

---

# 📊 Service Comparison

| Feature | ClusterIP | NodePort | LoadBalancer |
|---|---|---|---|
| Internal access | ✅ | ✅ | ✅ |
| External access | ❌ | ✅ | ✅ |
| Stable ClusterIP | ✅ | ✅ | ✅ |
| Node port | ❌ | ✅ | Usually ✅ |
| Cloud Load Balancer | ❌ | ❌ | ✅ |
| Common use | Internal services | Development/testing | Production/cloud |
| Default Service type | ✅ | ❌ | ❌ |

---

# 🎯 Final Takeaway

Pods are temporary, but Services provide a **stable way to communicate with them**.

```text
Deployment
     |
     v
Multiple Pods
     |
     v
   Service
     |
     +------------------+
     |                  |
     v                  v
 Stable IP          Stable DNS
     |
     v
Load Balancing
```

The three main Service types are:

```text
ClusterIP
    ↓
Internal cluster communication

NodePort
    ↓
External access through a node

LoadBalancer
    ↓
External access through a cloud load balancer
```

> **Key takeaway:** Pods can change, but a Service provides a stable endpoint and automatically routes traffic to the correct Pods.

---

# 📤 Submission

Add the following files to:

```text
2026/day-53/
```

```text
2026/
└── day-53/
    ├── app-deployment.yaml
    ├── clusterip-service.yaml
    ├── nodeport-service.yaml
    ├── loadbalancer-service.yaml
    └── day-53-services.md
```

Stage the files:

```bash
git add 2026/day-53/
```

Commit:

```bash
git commit -m "Day 53: Kubernetes Services"
```

Push:

```bash
git push
```

---

# 🚀 Learn in Public

> Learned Kubernetes Services today — ClusterIP for internal traffic, NodePort for node-level access, and LoadBalancer for production traffic. Services give Pods a stable identity and provide load balancing across multiple Pods.

```text
#90DaysOfDevOps
#DevOpsKaJosh
#TrainWithShubham
#Kubernetes
#DevOps
#CloudNative
```

---

## Day 53 Completed ✅

Today I learned:

- [x] Kubernetes Services
- [x] ClusterIP
- [x] NodePort
- [x] LoadBalancer
- [x] Service selectors
- [x] Service endpoints
- [x] Kubernetes DNS
- [x] Pod-to-Service communication
- [x] Service load balancing
- [x] Service troubleshooting

