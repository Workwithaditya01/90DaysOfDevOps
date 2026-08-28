# Day 59 – Helm: Kubernetes Package Manager

## 1. What is Helm?

Helm is the **package manager for Kubernetes** — the equivalent of `apt` for
Ubuntu, `brew` for macOS, or `npm` for Node.js. Instead of writing and
tracking a Deployment, a Service, a ConfigMap, a Secret, and a PVC by hand
every time you want to run an application, Helm lets you install a
pre-packaged, parameterized bundle of manifests with a single command.

### The three core concepts

| Concept        | What it is                                                                                     | Analogy                          |
|----------------|--------------------------------------------------------------------------------------------------|-----------------------------------|
| **Chart**      | A package of Kubernetes manifest **templates** plus default configuration (`values.yaml`)        | A `.deb` / `.apt` package         |
| **Release**    | A specific, named **installation** of a chart into a cluster, with its own revision history       | An installed application instance |
| **Repository** | A collection of charts, hosted over HTTP, that can be searched and pulled from                    | `apt`'s package repositories      |

A single chart can be installed **multiple times** with different names and
different values — each installation is its own independent Release.

---

## 2. Installing Helm

Installed via the official install script (works the same as `brew install
helm` on macOS or the Chocolatey package on Windows):

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verification commands:

```bash
helm version
# version.BuildInfo{Version:"v3.16.x", GitCommit:"...", GitTreeState:"clean", GoVersion:"go1.22.x"}

helm env
# HELM_BIN=helm
# HELM_CACHE_HOME=/home/user/.cache/helm
# HELM_CONFIG_HOME=/home/user/.config/helm
# HELM_DATA_HOME=/home/user/.local/share/helm
# HELM_REPOSITORY_CONFIG=/home/user/.config/helm/repositories.yaml
# ...
```

**Verify — installed version:** `v3.16.x` (Helm 3, no Tiller server-side
component — Helm 3 talks to the Kubernetes API directly using the same
kubeconfig as `kubectl`).

---

## 3. Adding a Repository and Searching

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Search for a specific chart or browse everything in a repo:

```bash
helm search repo nginx
# NAME                    CHART VERSION   APP VERSION   DESCRIPTION
# bitnami/nginx           18.x.x          1.27.x        NGINX Open Source is a web server...

helm search repo bitnami
```

**Verify — how many charts does Bitnami have?** Running `helm search repo
bitnami` lists on the order of **100+ charts** (Bitnami maintains
production-ready charts for most popular open source software — databases,
message queues, web servers, monitoring stacks, etc.). The exact count
changes over time as charts are added/deprecated, so the authoritative
number is whatever your local `helm search repo bitnami | wc -l` reports at
the time you run it.

---

## 4. Installing a Chart

```bash
helm install my-nginx bitnami/nginx
kubectl get all
```

This single `helm install` creates, in one shot, what would otherwise be a
Deployment, a Service, and a ConfigMap written by hand:

```bash
helm list
# NAME        NAMESPACE   REVISION  STATUS    CHART         APP VERSION
# my-nginx    default     1         deployed  nginx-18.x.x  1.27.x

helm status my-nginx
helm get manifest my-nginx    # shows the fully-rendered YAML that was applied
```

**Verify:**
- **Pods running:** 1 (the chart's default `replicaCount` is `1`)
- **Service type created:** `LoadBalancer` (Bitnami's nginx chart defaults to
  `LoadBalancer`; on a local cluster like Minikube/kind this stays
  `<pending>` for `EXTERNAL-IP` unless a load-balancer controller/tunnel is
  running)

---

## 5. Customizing with Values

Every chart ships a `values.yaml` with sane defaults. You can override any
of them without touching the chart itself.

View the full set of configurable options:

```bash
helm show values bitnami/nginx
```

**Inline overrides** with `--set`:

```bash
helm install my-nginx-set bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=NodePort
```

**File-based overrides** — see [`custom-values.yaml`](./custom-values.yaml)
in this folder, which sets `replicaCount`, `service.type`, and CPU/memory
`resources`:

```bash
helm install my-nginx-custom bitnami/nginx -f custom-values.yaml
```

Check what was actually overridden for a release:

```bash
helm get values my-nginx-custom
# USER-SUPPLIED VALUES:
# replicaCount: 3
# resources:
#   limits: {cpu: 250m, memory: 256Mi}
#   requests: {cpu: 100m, memory: 128Mi}
# service:
#   type: NodePort

helm get values my-nginx-custom --all   # merged with full chart defaults
```

**Verify:** `helm get values my-nginx-custom` confirms `replicaCount: 3` and
`service.type: NodePort`, and `kubectl get pods` / `kubectl get svc` show 3
Pods and a `NodePort` Service respectively — matching the file.

---

## 6. Upgrade and Rollback

Upgrades change a release in-place and record a new revision:

```bash
helm upgrade my-nginx bitnami/nginx --set replicaCount=5
helm history my-nginx
# REVISION  UPDATED          STATUS      CHART         DESCRIPTION
# 1         ...              superseded  nginx-18.x.x  Install complete
# 2         ...              deployed    nginx-18.x.x  Upgrade complete
```

Rolling back to a previous revision:

```bash
helm rollback my-nginx 1
helm history my-nginx
# REVISION  UPDATED          STATUS      CHART         DESCRIPTION
# 1         ...              superseded  nginx-18.x.x  Install complete
# 2         ...              superseded  nginx-18.x.x  Upgrade complete
# 3         ...              deployed    nginx-18.x.x  Rollback to 1
```

**Key insight:** rollback does **not** delete revision 2 or reuse revision
1's number — it creates a **new revision (3)** whose content matches
revision 1. This is the same append-only history model as a Deployment's
`kubectl rollout undo` from Day 52, just applied to the whole chart/release
instead of a single object.

**Verify:** After the rollback, `helm history my-nginx` shows **3
revisions** total.

---

## 7. Creating a Custom Chart

Scaffold a new chart:

```bash
helm create my-app
```

This generates:

```
my-app/
├── Chart.yaml            # chart metadata: name, version, appVersion
├── values.yaml           # default configuration values
├── charts/               # subcharts/dependencies go here
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── serviceaccount.yaml
    ├── hpa.yaml
    ├── _helpers.tpl       # reusable named template snippets
    ├── NOTES.txt          # printed to the user after install
    └── tests/
        └── test-connection.yaml
```

### How the Go templating works

Templates use Go's `text/template` syntax. Values are pulled from three
main objects:

- `{{ .Values.xxx }}` — pulled from `values.yaml` (or `--set` / `-f`
  overrides)
- `{{ .Chart.Name }}` / `{{ .Chart.Version }}` — metadata from `Chart.yaml`
- `{{ .Release.Name }}` / `{{ .Release.Namespace }}` — info about the
  specific installation

Example snippet from `templates/deployment.yaml`:

```yaml
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
```

At install/upgrade time, Helm renders these templates by substituting the
real values, producing plain Kubernetes YAML, then applies it — exactly as
if you'd written that YAML by hand.

### Customizing `values.yaml`

Edited to:

```yaml
replicaCount: 3
image:
  repository: nginx
  tag: "1.25"
```

### Validate, preview, install, upgrade

```bash
helm lint my-app
# ==> Linting my-app
# 1 chart(s) linted, 0 chart(s) failed

helm template my-release ./my-app       # renders final YAML, no install
helm install my-release ./my-app
kubectl get pods -l app.kubernetes.io/instance=my-release
# 3 Pods running, each using nginx:1.25

helm upgrade my-release ./my-app --set replicaCount=5
kubectl get pods -l app.kubernetes.io/instance=my-release
# 5 Pods running
```

**Verify:**
- After install: **3 replicas** (from the edited `values.yaml`)
- After upgrade: **5 replicas** (from the `--set` override, which takes
  precedence over `values.yaml`)

---

## 8. Clean Up

```bash
helm uninstall my-nginx
helm uninstall my-nginx-set
helm uninstall my-nginx-custom
helm uninstall my-release

rm -rf my-app custom-values.yaml   # (kept a copy for this submission)

helm list
# NAME  NAMESPACE  REVISION  STATUS  CHART  APP VERSION
# (empty)
```

Use `helm uninstall <name> --keep-history` instead if you want the release
history retained for auditing even after the resources are removed.

**Verify:** `helm list` returns **zero releases** after cleanup.

---

## 9. Summary — Why This Matters

Before today: a real application meant hand-writing and tracking a
Deployment, Service, ConfigMap, Secret, and PVC as separate YAML files, and
manually re-applying each one on every change.

With Helm:
- **Install** = one command (`helm install`) instead of `kubectl apply -f`
  across many files
- **Customize** = override just the values that differ (`--set` / `-f`)
  instead of editing YAML directly
- **Upgrade / Rollback** = versioned, atomic, one command each
  (`helm upgrade`, `helm rollback`), with full history via `helm history`
- **Reuse** = the same chart can be installed many times (dev, staging,
  prod) with different value files, instead of copy-pasting YAML

This is the same rollout/rollback concept from Day 52's Deployments, now
operating at the level of an entire application stack.

See [`custom-values.yaml`](./custom-values.yaml) for the values override
file used in Task 4.
