# Day 54 – Kubernetes ConfigMaps and Secrets
 
## Overview
 
Kubernetes applications need configuration data — database URLs, feature flags,
API keys, ports, credentials — but baking these values into a container image
means rebuilding and re-pushing the image every time something changes.
Kubernetes decouples config from code using two API objects:
 
- **ConfigMap** — stores non-sensitive configuration data as key-value pairs
  or whole files.
- **Secret** — stores sensitive data (passwords, tokens, keys) in a similar
  key-value/file structure, base64-encoded at rest in etcd, with extra
  handling (tmpfs mounts, RBAC restrictions).
Both can be injected into Pods as **environment variables** or as **mounted
volumes**, and both can be created imperatively (`kubectl create`) or
declaratively (YAML manifests).
 
---
 
## Task 1: Create a ConfigMap from Literals
 
### Command
 
```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  --from-literal=APP_PORT=8080
```
 
### Inspect
 
```bash
kubectl describe configmap app-config
kubectl get configmap app-config -o yaml
```
 
### Sample output (`-o yaml`)
 
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: production
  APP_DEBUG: "false"
  APP_PORT: "8080"
```
 
### Explanation
 
`--from-literal=KEY=VALUE` is the fastest way to create small ConfigMaps
directly from the command line. Each `--from-literal` flag adds one key to
the ConfigMap's `data` map. Running `describe` shows a human-readable summary
of the keys; `get -o yaml` shows the raw manifest.
 
**Verify:** Yes — `data` contains all three keys (`APP_ENV`, `APP_DEBUG`,
`APP_PORT`) as plain, readable text. There is no encoding or encryption
applied — ConfigMaps are meant for non-sensitive data only.
 
---
 
## Task 2: Create a ConfigMap from a File
 
### `default.conf`
 
```nginx
server {
    listen 80;
 
    location /health {
        default_type text/plain;
        return 200 "healthy\n";
    }
 
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
```
 
### Command
 
```bash
kubectl create configmap nginx-config --from-file=default.conf=default.conf
```
 
### Inspect
 
```bash
kubectl get configmap nginx-config -o yaml
```
 
### Sample output
 
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  default.conf: |
    server {
        listen 80;
 
        location /health {
            default_type text/plain;
            return 200 "healthy\n";
        }
 
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
    }
```
 
### Explanation
 
`--from-file=key=path` reads the entire file and stores it as a single value
under the given key. When this ConfigMap is later mounted into a Pod as a
volume, Kubernetes writes the value out as a **file** named after the key —
in this case `default.conf` — inside the mount directory. This is how whole
config files (nginx.conf, application.yaml, etc.) are delivered to
containers without baking them into the image.
 
**Verify:** Yes — `kubectl get configmap nginx-config -o yaml` shows the full
contents of `default.conf`, including the `/health` block, under `data`.
 
---
 
## Task 3: Use ConfigMaps in a Pod
 
### Pod 1 — inject `app-config` as environment variables
 
`pod-env-configmap.yaml`:
 
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-env-pod
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "env | grep APP_ && sleep 3600"]
      envFrom:
        - configMapRef:
            name: app-config
  restartPolicy: Never
```
 
```bash
kubectl apply -f pod-env-configmap.yaml
kubectl logs app-env-pod
```
 
Expected log output:
 
```
APP_ENV=production
APP_DEBUG=false
APP_PORT=8080
```
 
### Pod 2 — mount `nginx-config` as a volume
 
`pod-volume-configmap.yaml`:
 
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-config-pod
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
  volumes:
    - name: config-volume
      configMap:
        name: nginx-config
```
 
```bash
kubectl apply -f pod-volume-configmap.yaml
kubectl exec nginx-config-pod -- curl -s http://localhost/health
```
 
Expected output:
 
```
healthy
```
 
### Explanation
 
- `envFrom.configMapRef` dumps **every** key in the ConfigMap into the
  container's environment — good for a handful of simple settings.
- `volumes.configMap` + `volumeMounts` writes each key as a **file** at the
  mount path, overlaying (or adding to) whatever is already there. This is
  the correct approach for full config files like `nginx.conf`, because
  Nginx reads its config from disk, not from environment variables.
**Verify:** `curl -s http://localhost/health` inside the Pod returns
`healthy`, confirming the mounted `default.conf` was picked up by Nginx.
 
---
 
## Task 4: Create a Secret
 
### Command
 
```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD='s3cureP@ssw0rd'
```
 
### Inspect
 
```bash
kubectl get secret db-credentials -o yaml
```
 
### Sample output
 
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  DB_USER: YWRtaW4=
  DB_PASSWORD: czNjdXJlUEBzc3cwcmQ=
```
 
### Decode
 
```bash
echo 'czNjdXJlUEBzc3cwcmQ=' | base64 --decode
# s3cureP@ssw0rd
```
 
Or directly from the object:
 
```bash
kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
```
 
### Explanation
 
`kubectl create secret generic` works just like ConfigMap creation but
stores each value **base64-encoded** in `data`. This is *not* encryption —
base64 is a reversible encoding scheme with no key, so anyone who can read
the Secret object (e.g., via `kubectl get secret -o yaml` or direct etcd
access) can trivially decode it back to plaintext. The real protection comes
from **who is allowed to read the object at all** (RBAC), not from the
encoding itself.
 
**Verify:** Yes — decoding `czNjdXJlUEBzc3cwcmQ=` returns `s3cureP@ssw0rd`,
the original plaintext password.
 
---
 
## Task 5: Use Secrets in a Pod
 
`pod-secret.yaml`:
 
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: db-secret-pod
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "sleep 3600"]
      env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_USER
      volumeMounts:
        - name: secret-volume
          mountPath: /etc/db-credentials
          readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: db-credentials
```
 
```bash
kubectl apply -f pod-secret.yaml
 
# check the env var
kubectl exec db-secret-pod -- env | grep DB_USER
 
# check the mounted files
kubectl exec db-secret-pod -- ls /etc/db-credentials
kubectl exec db-secret-pod -- cat /etc/db-credentials/DB_USER
kubectl exec db-secret-pod -- cat /etc/db-credentials/DB_PASSWORD
```
 
Expected:
 
```
DB_USER=admin
DB_USER
DB_PASSWORD
admin
s3cureP@ssw0rd
```
 
### Explanation
 
- `env.valueFrom.secretKeyRef` pulls a **single** named key out of the
  Secret into one environment variable — use this when you only need one or
  two values.
- Mounting the whole Secret as a volume with `readOnly: true` creates one
  file per key inside `/etc/db-credentials`, and — importantly — Kubernetes
  **automatically base64-decodes** the values before writing them to disk.
  The container never has to decode anything itself.
**Verify:** The mounted files (`DB_USER`, `DB_PASSWORD`) contain **plaintext**
values (`admin`, `s3cureP@ssw0rd`), not base64 — decoding happens on the
kubelet side when the volume is populated.
 
---
 
## Task 6: Update a ConfigMap and Observe Propagation
 
### Create the ConfigMap
 
```bash
kubectl create configmap live-config --from-literal=message=hello
```
 
### Pod that watches the mounted file
 
`pod-live-config.yaml`:
 
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: live-config-pod
spec:
  containers:
    - name: watcher
      image: busybox
      command: ["sh", "-c", "while true; do cat /etc/config/message; echo; sleep 5; done"]
      volumeMounts:
        - name: config-volume
          mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: live-config
```
 
```bash
kubectl apply -f pod-live-config.yaml
kubectl logs -f live-config-pod
```
 
### Update the ConfigMap
 
```bash
kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'
```
 
Wait 30–60 seconds and watch the log stream — the printed value flips from
`hello` to `world` **without restarting the Pod**.
 
### Explanation
 
The kubelet periodically re-syncs ConfigMap/Secret volumes it has mounted
(the default sync period is roughly 1 minute, sometimes faster depending on
the kubelet's cache TTL). When the underlying object changes, the projected
files on disk are updated in place, so any process re-reading the file (as
the loop above does) picks up the new value automatically.
 
Environment variables behave completely differently: they are resolved
**once**, at container start, by the kubelet reading the ConfigMap/Secret at
that moment and injecting the values into the container's process
environment. There is no ongoing link between the running container and the
ConfigMap object — updating the ConfigMap has zero effect on an env var
already set in a running Pod. The only way to pick up a changed value via
env vars is to restart/recreate the Pod.
 
**Verify:** Yes — the volume-mounted value updates from `hello` to `world`
live, with no Pod restart. (Contrast this with Task 3/Task 5's `envFrom` /
`valueFrom` Pods — updating `app-config` or `db-credentials` would **not**
change their already-running environment variables.)
 
---
 
## Task 7: Clean Up
 
```bash
kubectl delete pod app-env-pod nginx-config-pod db-secret-pod live-config-pod
 
kubectl delete configmap app-config nginx-config live-config
kubectl delete secret db-credentials
```
 
Verify everything is gone:
 
```bash
kubectl get pods
kubectl get configmap
kubectl get secret
```
 
---
 
## Documentation
 
### What are ConfigMaps and Secrets, and when to use each?
 
Both are Kubernetes objects that decouple configuration from container
images so the same image can run in dev, staging, and prod with different
settings, and so config changes don't require rebuilding/redeploying images.
 
- **ConfigMap** — non-sensitive configuration: environment names, feature
  flags, ports, full config files (nginx.conf, application.properties,
  etc.). Data is stored as plain text.
- **Secret** — sensitive configuration: passwords, API tokens, TLS certs,
  SSH keys. Data is stored base64-encoded, kept in tmpfs (in-memory) on
  nodes when mounted, and access can be restricted more tightly via RBAC.
  Encryption at rest in etcd is available but must be explicitly enabled by
  the cluster admin — it is not on by default.
Rule of thumb: **if leaking the value in a log or a `describe` output would
be a security incident, it belongs in a Secret; otherwise a ConfigMap is
fine.**
 
### Environment variables vs. volume mounts
 
| | Environment Variables | Volume Mounts |
|---|---|---|
| How it's injected | `envFrom` (all keys) or `env.valueFrom` (single key) | `volumes` + `volumeMounts` |
| Format inside container | `KEY=VALUE` process env vars | One file per key, file content = value |
| Best for | A handful of simple scalar settings (ports, flags, hostnames) | Full config files, or many keys, or anything an app reads from disk |
| Live updates | ❌ Never — fixed at container start | ✅ Yes — kubelet syncs changes to the mounted files automatically |
| Secret decoding | Kubelet decodes base64 before injecting the value | Kubelet decodes base64 before writing the file — container sees plaintext |
 
### Why base64 is encoding, not encryption
 
Base64 is a reversible **encoding** scheme for representing binary/text data
in a printable ASCII format — it has no key, no algorithmic secret, and no
concept of "authorized" vs "unauthorized" access. Anyone can decode a
base64 string with a single command (`base64 --decode`) or an online tool.
Storing a Secret's values as base64 does **not** protect them from anyone
who can already read the Secret object via the Kubernetes API or directly
from etcd.
 
The actual security value Secrets provide comes from:
- **RBAC** — restricting which users/service accounts can `get`/`list`
  Secret objects at all.
- **tmpfs storage** — when mounted as volumes, Secret data lives in
  in-memory filesystem on the node, not written to disk.
- **Optional encryption at rest** — cluster operators can configure etcd
  encryption providers so Secret data is actually encrypted in the
  underlying datastore (this is separate from, and in addition to, the
  base64 encoding used in the API representation).
### How ConfigMap updates propagate to volumes but not env vars
 
- **Volume-mounted** ConfigMaps/Secrets: the kubelet keeps a local cache of
  the object and periodically re-syncs it (typically within about a
  minute). When it detects a change, it rewrites the projected files on the
  node's filesystem, and the container sees the new content the next time
  it reads the file — no restart required. This is why Task 6's `while
  true; cat ...; sleep 5` loop eventually printed `world` after the patch.
- **Environment variables**: the kubelet resolves `envFrom`/`valueFrom`
  values exactly once, when the container process is started, and copies
  them into that process's environment block. The Linux process environment
  is immutable after start (short of exec'ing into the container and
  manually re-exporting a variable), and Kubernetes has no mechanism to
  "push" a new value into an already-running process's environment. The
  only way to apply an updated value via env vars is to delete/recreate the
  Pod (or trigger a rollout if it's managed by a Deployment).
---
 
## Key Takeaways
 
- ConfigMaps → non-sensitive config; Secrets → sensitive config (base64,
  not encrypted, by default).
- `envFrom`/`valueFrom` → simple scalar values, static for the Pod's
  lifetime.
- Volume mounts → full files, auto-updating, correct choice for anything an
  application reads off disk (like Nginx configs).
- base64 ≠ encryption — real protection comes from RBAC, tmpfs, and
  (optional) etcd encryption at rest.
- Only volume-mounted ConfigMaps/Secrets propagate live updates to running
  Pods; environment variables require a Pod restart.
 
