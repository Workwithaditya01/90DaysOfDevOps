# Day 55 – Persistent Volumes (PV) & Persistent Volume Claims (PVC)

Part of the **#90DaysOfDevOps** challenge by TrainWithShubham.

Containers are ephemeral — when a Pod dies, everything inside it disappears.
This day's task proves that with a live demo, then fixes it using
Kubernetes **PersistentVolumes** and **PersistentVolumeClaims**, and finally
shows how **StorageClasses** automate the whole thing via dynamic
provisioning.

---

## 📁 Folder structure

```
day-55/
├── README.md                      # you are here
├── day-55-persistent-volumes.md   # full write-up, concepts, and answers to every "Verify" question
└── manifests/
    ├── 01-emptydir-pod.yaml           # Task 1 – proves data is lost with emptyDir
    ├── 02-pv.yaml                     # Task 2 – manually created PersistentVolume
    ├── 03-pvc.yaml                    # Task 3 – PVC that binds to the manual PV
    ├── 04-pod-with-pvc.yaml           # Task 4 – Pod using the manual PVC, data survives
    ├── 05-pvc-dynamic.yaml            # Task 6 – PVC using a StorageClass (dynamic provisioning)
    └── 06-pod-with-dynamic-pvc.yaml   # Task 6 – Pod using the dynamically provisioned PVC
```

---

## ✅ Prerequisites

- A running Kubernetes cluster (minikube, kind, k3d, or any cloud cluster)
- `kubectl` configured to talk to that cluster
- A default `StorageClass` available in the cluster (check with
  `kubectl get storageclass`) if you want to run Task 6

---

## 🚀 Quick start — run everything in order

```bash
cd manifests

# Task 1 — see the problem
kubectl apply -f 01-emptydir-pod.yaml
kubectl exec emptydir-pod -- cat /data/message.txt
kubectl delete pod emptydir-pod
kubectl apply -f 01-emptydir-pod.yaml
kubectl exec emptydir-pod -- cat /data/message.txt   # different timestamp — data was lost

# Task 2 — create a PersistentVolume (static provisioning)
kubectl apply -f 02-pv.yaml
kubectl get pv                                       # STATUS: Available

# Task 3 — create a PersistentVolumeClaim
kubectl apply -f 03-pvc.yaml
kubectl get pvc                                      # STATUS: Bound
kubectl get pv                                        # STATUS: Bound

# Task 4 — use the PVC in a Pod, prove data survives
kubectl apply -f 04-pod-with-pvc.yaml
kubectl exec pvc-pod -- cat /data/message.txt
kubectl delete pod pvc-pod
kubectl apply -f 04-pod-with-pvc.yaml
kubectl exec pvc-pod -- cat /data/message.txt        # both messages present

# Task 5 — inspect StorageClasses
kubectl get storageclass
kubectl describe storageclass <default-class-name>

# Task 6 — dynamic provisioning
# ⚠️ Edit storageClassName in 05-pvc-dynamic.yaml to match your cluster's
#    default StorageClass if it isn't "standard"
kubectl apply -f 05-pvc-dynamic.yaml
kubectl get pv                                        # a new PV appears automatically
kubectl apply -f 06-pod-with-dynamic-pvc.yaml
kubectl exec dynamic-pvc-pod -- cat /data/message.txt

# Task 7 — clean up
kubectl delete pod emptydir-pod pvc-pod dynamic-pvc-pod --ignore-not-found
kubectl delete pvc pvc-manual pvc-dynamic
kubectl get pv                                         # dynamic PV is gone (Delete policy)
                                                          # manual PV shows Released (Retain policy)
kubectl delete pv pv-manual-hostpath
```

---

## 📖 Full documentation

See [`day-55-persistent-volumes.md`](./day-55-persistent-volumes.md) for:

- Why containers need persistent storage
- What PVs and PVCs are and how they relate
- Static vs dynamic provisioning
- Access modes (`RWO`, `ROX`, `RWX`) and reclaim policies (`Retain`, `Delete`)
- Line-by-line breakdown of every manifest
- Answers to every task's "Verify" question

---

## 🔑 Key takeaways

| Concept | One-line summary |
|---|---|
| `emptyDir` | Volume tied to the **Pod's** lifecycle — gone when the Pod is deleted |
| `PersistentVolume (PV)` | Cluster-scoped storage resource, exists independently of any Pod |
| `PersistentVolumeClaim (PVC)` | Namespaced request for storage; binds to a matching PV |
| Static provisioning | Admin manually creates the PV ahead of time |
| Dynamic provisioning | A `StorageClass` auto-creates the PV when a matching PVC is created |
| `Retain` reclaim policy | Keep data + PV object after the PVC is deleted |
| `Delete` reclaim policy | Auto-delete the PV and underlying storage when the PVC is deleted |

---

## 📢 Learn in Public

> Learned Kubernetes Persistent Volumes and PVCs today. Proved container
> data is ephemeral, then fixed it with PVs. Also explored dynamic
> provisioning with StorageClasses.
>
> `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

---

**Happy Learning!** — TrainWithShubham
