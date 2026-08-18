# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)

Containers are ephemeral. When a Pod's container restarts or the Pod is
deleted, the container's writable filesystem layer goes with it. For
stateless apps that's fine — for databases, message queues, or anything
that needs to remember something across restarts, it's a dealbreaker.
Kubernetes solves this with a storage abstraction: **PersistentVolumes
(PV)** and **PersistentVolumeClaims (PVC)**.

---

## Why containers need persistent storage

- A container's own filesystem is tied to its container instance. Once the
  container is removed, that layer is gone.
- Pods are meant to be disposable — scaled up/down, rescheduled,
  restarted after crashes. If application state lived only inside the
  container, every one of those normal Kubernetes operations would cause
  data loss.
- Storage needs to be **decoupled from the Pod's lifecycle**: the volume
  should outlive the Pod (and even survive the Pod being deleted and a new
  one created in its place).

---

## Task 1 — See the problem: data lost on Pod deletion

Manifest: `manifests/01-emptydir-pod.yaml` — uses an `emptyDir` volume,
which lives as long as the **Pod** (not the container) does, but is
deleted the moment the Pod itself is deleted.

```bash
kubectl apply -f manifests/01-emptydir-pod.yaml
kubectl exec emptydir-pod -- cat /data/message.txt

kubectl delete pod emptydir-pod
kubectl apply -f manifests/01-emptydir-pod.yaml
kubectl exec emptydir-pod -- cat /data/message.txt
```

**Verify — Is the timestamp the same or different after recreation?**
Different. `emptyDir` storage is created fresh with the Pod and destroyed
when the Pod is deleted, so the second Pod starts with a brand-new,
empty volume and writes a new timestamp. Nothing carries over.

---

## Task 2 — Create a PersistentVolume (static provisioning)

Manifest: `manifests/02-pv.yaml`

```yaml
capacity:
  storage: 1Gi
accessModes:
  - ReadWriteOnce
persistentVolumeReclaimPolicy: Retain
hostPath:
  path: /tmp/k8s-pv-data
```

```bash
kubectl apply -f manifests/02-pv.yaml
kubectl get pv
```

**Verify — What is the STATUS of the PV?**
`Available` — it exists and satisfies capacity/access-mode requirements,
but no PVC has claimed it yet.

---

## Task 3 — Create a PersistentVolumeClaim

Manifest: `manifests/03-pvc.yaml` — requests `500Mi`, `ReadWriteOnce`.
`storageClassName: ""` is set so the PVC does **not** trigger dynamic
provisioning and instead binds to the manual PV from Task 2.

```bash
kubectl apply -f manifests/03-pvc.yaml
kubectl get pvc
kubectl get pv
```

**Verify — What does the VOLUME column in `kubectl get pvc` show?**
The name of the PV it got bound to (`pv-manual-hostpath`). Kubernetes'
control loop matches PVCs to PVs by comparing requested size/access mode
against available PVs and binds the smallest PV that satisfies the
request. Both `kubectl get pvc` and `kubectl get pv` now show `Bound`.

---

## Task 4 — Use the PVC in a Pod: data that survives

Manifest: `manifests/04-pod-with-pvc.yaml` mounts the PVC at `/data` via
`persistentVolumeClaim.claimName: pvc-manual`.

```bash
kubectl apply -f manifests/04-pod-with-pvc.yaml
kubectl exec pvc-pod -- cat /data/message.txt

kubectl delete pod pvc-pod
kubectl apply -f manifests/04-pod-with-pvc.yaml
kubectl exec pvc-pod -- cat /data/message.txt
```

**Verify — Does the file contain data from both the first and second Pod?**
Yes. Because the container command appends (`>>`) rather than overwrites,
and the PVC is bound to a PV backed by `/tmp/k8s-pv-data` on the host,
the file survives Pod deletion. The second Pod mounts the *same*
underlying storage, so `cat` shows both timestamped lines.

---

## Task 5 — StorageClasses and dynamic provisioning

```bash
kubectl get storageclass
kubectl describe storageclass <name>
```

Look at three fields in the describe output:
- **Provisioner** — the plugin that actually creates the backing volume
  (e.g. `kubernetes.io/aws-ebs`, `rancher.io/local-path`, `kubernetes.io/host-path`, `docker.io/hostpath`, depending on the cluster type — kind/minikube/k3d each ship a different default provisioner).
- **ReclaimPolicy** — what happens to the volume when its PVC is deleted
  (commonly `Delete` by default for dynamic classes).
- **VolumeBindingMode** — `Immediate` (PV created as soon as PVC is
  created) or `WaitForFirstConsumer` (PV creation deferred until a Pod
  using the PVC is scheduled, so the provisioner can pick the right
  zone/node).

**Verify — What is the default StorageClass in your cluster?**
Run `kubectl get storageclass` and look for the one annotated
`(default)` next to its name — this is the StorageClass used when a PVC
doesn't specify `storageClassName` at all. The exact name varies by
cluster (`standard` on minikube/GKE, `local-path` on k3d/k3s, etc.) —
record whatever your `kubectl get storageclass` output actually shows.

---

## Task 6 — Dynamic provisioning

Manifest: `manifests/05-pvc-dynamic.yaml` sets
`storageClassName: standard` (swap in your cluster's actual default
StorageClass name if it isn't `standard`).

```bash
kubectl apply -f manifests/05-pvc-dynamic.yaml
kubectl get pv
kubectl get pvc

kubectl apply -f manifests/06-pod-with-dynamic-pvc.yaml
kubectl exec dynamic-pvc-pod -- cat /data/message.txt
```

No PV manifest was written for this one — the StorageClass's provisioner
created the PV automatically the moment the PVC was created (or, under
`WaitForFirstConsumer`, once the Pod using it was scheduled).

**Verify — How many PVs exist now? Which was manual, which was dynamic?**
Two PVs:
- `pv-manual-hostpath` — created by hand in Task 2 (static provisioning).
- An auto-generated PV with a generated name like
  `pvc-<uuid>` — created by the StorageClass's provisioner in response to
  the `pvc-dynamic` claim (dynamic provisioning). Its `RECLAIM POLICY`
  will typically be `Delete`, unlike the manual PV's `Retain`.

---

## Task 7 — Clean up

```bash
kubectl delete pod emptydir-pod pvc-pod dynamic-pvc-pod --ignore-not-found

kubectl delete pvc pvc-manual pvc-dynamic
kubectl get pv
```

**Verify — Which PV was auto-deleted and which was retained? Why?**
- `pvc-dynamic`'s backing PV disappears entirely — its reclaim policy was
  `Delete` (the StorageClass default), so Kubernetes deletes both the PV
  object and the underlying storage as soon as its claim is removed.
- `pv-manual-hostpath` survives, but changes STATUS from `Bound` to
  `Released` — its reclaim policy is `Retain`, so Kubernetes leaves the
  PV object and the data on disk intact for manual recovery, but it can't
  be bound to a new PVC until an admin clears `claimRef` (or deletes and
  recreates the PV).

```bash
kubectl delete pv pv-manual-hostpath
kubectl delete pv <auto-generated-name-if-still-present>
```

---

## Concepts summary

### What PVs and PVCs are, and how they relate

- **PersistentVolume (PV)** — a cluster-scoped piece of storage
  provisioned by an admin (static) or a StorageClass provisioner
  (dynamic). It exists independently of any Pod and has its own
  lifecycle.
- **PersistentVolumeClaim (PVC)** — a namespaced *request* for storage
  made by a user/app: "I need X GiB with access mode Y." Kubernetes binds
  it to a PV that satisfies the request.
- **Pod** — mounts a PVC (not a PV directly) via
  `spec.volumes[].persistentVolumeClaim.claimName`. The Pod doesn't care
  where the storage physically lives; that's abstracted behind the PVC/PV
  layer.
- Relationship: `Pod → PVC → PV → actual storage backend`. This
  indirection means Pods can be deleted and recreated freely, and as long
  as they reference the same PVC, they reattach to the same data.

### Static vs dynamic provisioning

| | Static | Dynamic |
|---|---|---|
| Who creates the PV | Cluster admin, by hand | StorageClass provisioner, automatically |
| When | Ahead of time | On-demand, when a matching PVC is created |
| Use case | Fixed/legacy storage, learning, on-prem | Cloud environments, self-service for dev teams |
| Developer's job | Write PVC, hope it matches an existing PV | Just write PVC with a `storageClassName` |

With dynamic provisioning, developers stop thinking about PVs entirely —
they declare a PVC, the StorageClass handles the rest.

### Access modes

- **ReadWriteOnce (RWO)** — volume can be mounted read-write by a single
  node at a time (most common for databases).
- **ReadOnlyMany (ROX)** — many nodes can mount it read-only
  simultaneously.
- **ReadWriteMany (RWX)** — many nodes can mount it read-write at the
  same time (needs a storage backend that supports it, e.g. NFS,
  CephFS — not `hostPath`).

### Reclaim policies

- **Retain** — when the PVC is deleted, the PV and its data are kept
  (status becomes `Released`); an admin must manually clean up/reuse it.
  Safer for important data.
- **Delete** — when the PVC is deleted, the PV *and* the underlying
  storage are deleted automatically. Common default for dynamically
  provisioned volumes; convenient but destructive.
- **Recycle** — deprecated; used to do a basic scrub (`rm -rf`) of the
  volume for reuse. Not recommended in modern clusters.

---

## PV lifecycle (state machine)

```
Available  →  Bound  →  Released  →  (Deleted, or manually re-Available)
```

- **Available** — free, not yet claimed.
- **Bound** — matched to a PVC and in use.
- **Released** — the PVC was deleted, but the PV (with `Retain`) isn't
  reusable yet until an admin intervenes.
- **Failed** — automatic reclamation failed.

---

## Key hints/gotchas from today

- PVs are cluster-scoped; PVCs are namespaced.
- A PVC stuck in `Pending` almost always means no PV matches its
  requested capacity/access mode (or, for dynamic provisioning, the
  named StorageClass doesn't exist).
- `hostPath` ties data to a specific node — if the Pod is rescheduled
  elsewhere, the data appears "lost" even though it's still sitting on
  the original node's disk. Fine for learning, wrong for production.
- Setting `storageClassName: ""` on a PVC explicitly disables dynamic
  provisioning, forcing it to bind only to a manually created PV.
