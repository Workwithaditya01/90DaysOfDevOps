# Day 59 – Helm: Kubernetes Package Manager

Part of the [#90DaysOfDevOps](https://github.com/) challenge with
TrainWithShubham — `#DevOpsKaJosh` `#TrainWithShubham`

## 📌 Overview

Helm is the package manager for Kubernetes. Instead of hand-writing and
tracking separate Deployment, Service, ConfigMap, Secret, and PVC files,
Helm packages them into a single reusable **chart** that can be installed,
customized, upgraded, and rolled back with one command.

Today's exercise covered:

- Installing Helm and verifying the version
- Adding the Bitnami chart repository and searching it
- Installing a chart (`bitnami/nginx`) as a **release**
- Customizing a release with `--set` and a values file
- Upgrading a release and rolling it back (revision history)
- Scaffolding and customizing a brand-new chart with `helm create`
- Cleaning up releases

## 📂 Contents

| File                                        | Description                                                                 |
|----------------------------------------------|------------------------------------------------------------------------------|
| [`day-59-helm.md`](./day-59-helm.md)         | Full write-up: concepts, commands used, and answers to every verification step |
| [`custom-values.yaml`](./custom-values.yaml) | Values override file used to customize the `bitnami/nginx` release (replica count, service type, resource limits) |

## 🚀 Quick Reference

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# Add a repo and search
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo nginx

# Install a chart
helm install my-nginx bitnami/nginx

# Customize with a values file
helm install my-nginx-custom bitnami/nginx -f custom-values.yaml

# Upgrade and rollback
helm upgrade my-nginx bitnami/nginx --set replicaCount=5
helm history my-nginx
helm rollback my-nginx 1

# Create your own chart
helm create my-app
helm lint my-app
helm template my-release ./my-app
helm install my-release ./my-app

# Clean up
helm uninstall my-nginx my-nginx-custom my-release
helm list
```

## 🧠 Key Concepts

| Term           | Meaning                                                              |
|----------------|-----------------------------------------------------------------------|
| **Chart**      | A package of Kubernetes manifest templates + default config           |
| **Release**    | A named installation of a chart in the cluster (versioned, upgradable) |
| **Repository** | A hosted collection of charts (e.g., Bitnami)                         |

See [`day-59-helm.md`](./day-59-helm.md) for the full walkthrough, including
Go templating syntax (`{{ .Values }}`, `{{ .Chart }}`, `{{ .Release }}`) and
detailed answers to each task's verification questions.

---

📖 **Full details:** [`day-59-helm.md`](./day-59-helm.md)
⚙️ **Values file:** [`custom-values.yaml`](./custom-values.yaml)
