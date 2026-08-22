# Day 56 – Kubernetes StatefulSets

## Task
Deployments work great for stateless apps, but what about databases? You need stable pod names, ordered startup, and persistent storage per replica. Today's focus: StatefulSets — the workload designed for stateful applications like MySQL, PostgreSQL, and Kafka.

---

## Expected Output
- ✅ A StatefulSet with 3 replicas and stable pod names
- ✅ DNS resolution tested for individual pods
- ✅ Data persistence verified across pod deletion
- ✅ This markdown file: `day-56-statefulsets.md`

---

## Task 1: Understand the Problem

```bash
kubectl create deployment web --image=nginx --replicas=3
kubectl get pods -o wide
```

Pod names came back random: `web-7d9f8c6b95-x2f4k`, `web-7d9f8c6b95-p8qz1`, `web-7d9f8c6b95-m4vwt`.

```bash
kubectl delete pod web-7d9f8c6b95-x2f4k
kubectl get pods
```

The replacement pod showed up with a **completely different random name** — the ReplicaSet doesn't care about identity, only about maintaining the desired *count* of pods.

This is fine for a web server (any replica can serve any request), but not for a database where a specific node might be the primary, hold a specific shard, or be expected at a specific hostname by its peers.

```bash
kubectl delete deployment web
```

| Feature | Deployment | StatefulSet |
|---|---|---|
| Pod names | Random | Stable, ordered (`app-0`, `app-1`) |
| Startup order | All at once | Ordered: pod-0, then pod-1, then pod-2 |
| Storage | Shared PVC | Each pod gets its own PVC |
| Network identity | No stable hostname | Stable DNS per pod |

**Verify: Why would random pod names be a problem for a database cluster?**
Database clusters depend on knowing exactly which node is which — e.g. which node is the primary vs replica, or which node owns which shard of data. Replication configs, peer discovery, and cluster membership are often wired to specific hostnames. If a pod's name (and therefore its network identity) changes every time it restarts, the rest of the cluster loses track of it, replication breaks, and there's no guarantee the "new" pod reconnects to the data the "old" one was using. Random identity works for stateless replicas; it actively breaks stateful ones.

---

## Task 2: Create a Headless Service

```yaml
# headless-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
spec:
  clusterIP: None
  selector:
    app: web
  ports:
    - port: 80
      name: web
```

```bash
kubectl apply -f headless-svc.yaml
kubectl get svc nginx-headless
```

A Headless Service creates individual DNS entries for each matching pod instead of load-balancing to a single virtual IP. This is required by StatefulSets so that each pod is individually addressable.

**Verify: What does the CLUSTER-IP column show?**
`None` — this confirms it's headless. No virtual IP is allocated; DNS lookups against the service name resolve directly to each pod's individual IP instead of one load-balanced address.

---

## Task 3: Create a StatefulSet

```yaml
# statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: nginx-headless
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - name: web-data
              mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
    - metadata:
        name: web-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 100Mi
```

```bash
kubectl apply -f statefulset.yaml
kubectl get pods -l app=web -w
```

Observed ordered creation — `web-0` was created first and had to reach `Ready` before `web-1` was created, which had to reach `Ready` before `web-2` was created.

```bash
kubectl get pvc
```

**Verify: What are the exact pod names and PVC names?**
- Pods: `web-0`, `web-1`, `web-2`
- PVCs: `web-data-web-0`, `web-data-web-1`, `web-data-web-2`

(Naming pattern: `<volumeClaimTemplate name>-<statefulset name>-<ordinal>`)

---

## Task 4: Stable Network Identity

Each StatefulSet pod gets a DNS name in the form:
`<pod-name>.<service-name>.<namespace>.svc.cluster.local`

```bash
kubectl run -it --rm dns-test --image=busybox:1.36 --restart=Never -- sh
```

Inside the busybox shell:

```bash
nslookup web-0.nginx-headless.default.svc.cluster.local
nslookup web-1.nginx-headless.default.svc.cluster.local
nslookup web-2.nginx-headless.default.svc.cluster.local
```

Compared results against:

```bash
kubectl get pods -o wide
```

**Verify: Does the nslookup IP match the pod IP?**
Yes. Each `nslookup` returned exactly one IP, and it matched that specific pod's IP from `kubectl get pods -o wide`. This confirms the headless service is resolving pod-by-pod rather than load-balancing — `web-0`'s DNS name always points at `web-0`, never at a random member of the set.

---

## Task 5: Stable Storage — Data Survives Pod Deletion

```bash
kubectl exec web-0 -- sh -c "echo 'Data from web-0' > /usr/share/nginx/html/index.html"
kubectl exec web-0 -- cat /usr/share/nginx/html/index.html
```

```bash
kubectl delete pod web-0
kubectl get pods -w
```

Once the replacement `web-0` was `Running` and `Ready`:

```bash
kubectl exec web-0 -- cat /usr/share/nginx/html/index.html
```

**Verify: Is the data identical after pod recreation?**
Yes — output was still `Data from web-0`. Kubernetes recreated the pod under the same name (`web-0`) and reattached it to the same PVC (`web-data-web-0`), so the underlying volume — and everything written to it — was untouched by the pod's deletion.

---

## Task 6: Ordered Scaling

Scale up:

```bash
kubectl scale statefulset web --replicas=5
kubectl get pods -l app=web -w
```

`web-3` was created first and reached `Ready` before `web-4` was created.

Scale down:

```bash
kubectl scale statefulset web --replicas=3
kubectl get pods -l app=web -w
```

Termination happened in **reverse order**: `web-4` was terminated first, then `web-3`.

```bash
kubectl get pvc
```

**Verify: After scaling down, how many PVCs exist?**
All **5** PVCs (`web-data-web-0` through `web-data-web-4`) still exist, even though only 3 pods are running. Kubernetes never deletes PVCs on scale-down — it preserves them so that scaling back up to 5 would reattach `web-3` and `web-4` to their original data instead of starting fresh.

---

## Task 7: Clean Up

```bash
kubectl delete statefulset web
kubectl delete svc nginx-headless
kubectl get pvc
```

**Verify: Were PVCs auto-deleted with the StatefulSet?**
No. All PVCs remained after deleting both the StatefulSet and the headless Service. This is a deliberate safety feature — Kubernetes never silently destroys stateful data just because the controller managing it was removed. They must be deleted explicitly:

```bash
kubectl delete pvc web-data-web-0 web-data-web-1 web-data-web-2 web-data-web-3 web-data-web-4
```

---

## Key Concepts

**What StatefulSets are and when to use them vs Deployments**
A StatefulSet is a Kubernetes workload controller purpose-built for applications that need a persistent identity — a name, a network address, and a volume — that stays attached to the *same* replica across restarts and rescheduling. Use a Deployment when pods are disposable and interchangeable (web servers, stateless APIs). Use a StatefulSet when a specific replica needs to be found at the same address and reconnected to the same storage every time (databases, message queues, distributed/clustered systems like Kafka, Zookeeper, Cassandra, Elasticsearch).

**Headless Services**
Setting `clusterIP: None` tells Kubernetes not to allocate a load-balancing virtual IP. Instead, DNS (CoreDNS) publishes one record per matching pod. A StatefulSet's `serviceName` field must point to a headless Service like this — it's what makes per-pod addressing possible.

**Stable DNS**
Because each StatefulSet pod keeps its ordinal-based name (`web-0`, `web-1`, …) for its entire lifecycle, and the headless service maps that exact name to the pod's current IP, other workloads in the cluster can reliably reach "replica 0" by a fixed hostname — no service discovery logic or hardcoded IPs required.

**`volumeClaimTemplates`**
Rather than one shared PVC for the whole workload, the StatefulSet controller creates a dedicated PVC per replica, named `<template-name>-<statefulset-name>-<ordinal>`. Each pod always mounts its own PVC and keeps that same binding across pod deletion and rescheduling — this is what gives StatefulSets true per-replica persistence.

---

## Learn in Public
Shared on LinkedIn:
> "Learned Kubernetes StatefulSets today. Stable pod names, per-pod DNS, and persistent storage that survives deletion — now I understand why databases need StatefulSets."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
