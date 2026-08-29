# Day 60 – Capstone: Deploy WordPress + MySQL on Kubernetes

## 1. Overview

This capstone deploys a complete WordPress + MySQL stack inside a dedicated
`capstone` namespace, combining every major Kubernetes concept learned over
the last ten days: Namespaces, Secrets, ConfigMaps, a headless Service +
StatefulSet with persistent storage, a Deployment with liveness/readiness
probes, a NodePort Service, resource requests/limits, an HPA, and Helm (for
comparison).

All manifests below are exactly what was deployed, in application order.

---

## 2. Architecture

```
                        ┌───────────────────────────────┐
                        │     Namespace: capstone        │
                        │                                 │
   Browser ──30080──▶  │  Service: wordpress (NodePort)  │
                        │        │                        │
                        │        ▼                        │
                        │  Deployment: wordpress (x2)     │
                        │   - envFrom: wordpress-config   │
                        │   - secretKeyRef: mysql-secret  │
                        │     (WORDPRESS_DB_USER/PASSWORD)│
                        │   - liveness/readiness on       │
                        │     /wp-login.php:80            │
                        │        │                        │
                        │        │ mysql-0.mysql.capstone  │
                        │        │ .svc.cluster.local:3306 │
                        │        ▼                        │
                        │  Service: mysql (Headless)      │
                        │        │                        │
                        │        ▼                        │
                        │  StatefulSet: mysql (1 pod)     │
                        │   - envFrom: mysql-secret        │
                        │   - PVC (1Gi) → /var/lib/mysql  │
                        │                                 │
                        │  ConfigMap: wordpress-config    │
                        │  Secret: mysql-secret            │
                        │  HPA: wordpress-hpa (2-10, 50%) │
                        └───────────────────────────────┘
```

- The `wordpress` NodePort Service routes external traffic on `30080` to
  the WordPress pods.
- WordPress reads `WORDPRESS_DB_HOST` / `WORDPRESS_DB_NAME` from the
  `wordpress-config` ConfigMap, and `WORDPRESS_DB_USER` /
  `WORDPRESS_DB_PASSWORD` from `mysql-secret` via `secretKeyRef`.
- `WORDPRESS_DB_HOST` resolves because `mysql` is a **headless** Service
  (`clusterIP: None`), which gives the StatefulSet's pod a stable DNS name:
  `mysql-0.mysql.capstone.svc.cluster.local`.
- MySQL's data directory (`/var/lib/mysql`) is backed by a
  PersistentVolumeClaim generated from the StatefulSet's
  `volumeClaimTemplates`, so data survives pod restarts.
- `wordpress-hpa` scales the WordPress Deployment between 2 and 10 replicas
  based on CPU utilization.

---

## 3. Manifests

### 3.1 Namespace

```bash
kubectl create namespace capstone
kubectl config set-context --current --namespace=capstone
```

### 3.2 MySQL Secret — `mysql-secret.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: capstone
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: rootpassword
  MYSQL_DATABASE: wordpress
  MYSQL_USER: wordpress
  MYSQL_PASSWORD: wordpresspassword
```

### 3.3 MySQL Headless Service — `mysql-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: capstone
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
```

### 3.4 MySQL StatefulSet — `mysql-statefulset.yaml`

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: capstone
spec:
  serviceName: mysql
  replicas: 1

  selector:
    matchLabels:
      app: mysql

  template:
    metadata:
      labels:
        app: mysql

    spec:
      containers:
        - name: mysql
          image: mysql:8.0

          ports:
            - containerPort: 3306
              name: mysql

          envFrom:
            - secretRef:
                name: mysql-secret

          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: 500m
              memory: 1Gi

          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql

  volumeClaimTemplates:
    - metadata:
        name: mysql-data
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
```

### 3.5 WordPress ConfigMap — `wordpress-configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: wordpress-config
  namespace: capstone
data:
  WORDPRESS_DB_HOST: mysql-0.mysql.capstone.svc.cluster.local:3306
  WORDPRESS_DB_NAME: wordpress
```

### 3.6 WordPress Deployment — `wordpress-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: capstone
spec:
  replicas: 2

  selector:
    matchLabels:
      app: wordpress

  template:
    metadata:
      labels:
        app: wordpress

    spec:
      containers:
        - name: wordpress
          image: wordpress:latest

          ports:
            - containerPort: 80
              name: http

          envFrom:
            - configMapRef:
                name: wordpress-config

          env:
            - name: WORDPRESS_DB_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_USER

            - name: WORDPRESS_DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_PASSWORD

          resources:
            requests:
              cpu: 250m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 512Mi

          livenessProbe:
            httpGet:
              path: /wp-login.php
              port: 80
            initialDelaySeconds: 60
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 6

          readinessProbe:
            httpGet:
              path: /wp-login.php
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 6
```

### 3.7 WordPress NodePort Service — `wordpress-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: capstone
spec:
  type: NodePort
  selector:
    app: wordpress
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

### 3.8 WordPress HPA — `wordpress-hpa.yaml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: wordpress-hpa
  namespace: capstone
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: wordpress

  minReplicas: 2
  maxReplicas: 10

  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

---

## 4. Deployment order

```bash
kubectl apply -f mysql-secret.yaml
kubectl apply -f mysql-service.yaml
kubectl apply -f mysql-statefulset.yaml

# wait for mysql-0 to reach 1/1 Running
kubectl get pods -n capstone -w

kubectl apply -f wordpress-configmap.yaml
kubectl apply -f wordpress-deployment.yaml
kubectl apply -f wordpress-service.yaml
kubectl apply -f wordpress-hpa.yaml

kubectl get all -n capstone
kubectl get hpa -n capstone
```

---

## 5. Verification

**MySQL database check:**
```bash
kubectl exec -it mysql-0 -n capstone -- mysql -u wordpress -pwordpresspassword -e "SHOW DATABASES;"
```
Result: `wordpress` database is listed alongside `information_schema`,
confirming `MYSQL_DATABASE` triggered auto-creation on first boot.

**WordPress pod check:**
```bash
kubectl get pods -n capstone -l app=wordpress
```
Result: both replicas reached `1/1 Running` once the `/wp-login.php`
readiness probe began succeeding.

**Access the site:**
```bash
minikube service wordpress -n capstone
# or
kubectl port-forward svc/wordpress 8080:80 -n capstone
```
Result: WordPress setup wizard loaded; completed it and published a test
blog post.

---

## 6. Self-healing & persistence test results

| Test | Action | Observation |
|---|---|---|
| WordPress self-healing | `kubectl delete pod <wordpress-pod-name> -n capstone` | ReplicaSet created a replacement pod within seconds; site stayed reachable via the other replica |
| MySQL self-healing | `kubectl delete pod mysql-0 -n capstone` | StatefulSet recreated `mysql-0` with the same name and re-attached the same PVC (`mysql-data-mysql-0`) |
| Data persistence | Refreshed WordPress after `mysql-0` recovered | Blog post created earlier was still present |
| Combined test | Deleted both a WordPress pod and `mysql-0` | After both recovered, the site and blog post were intact |

**Conclusion:** the Deployment and StatefulSet controllers both restore pod
availability automatically. Because MySQL's data directory is mounted from
a PersistentVolumeClaim rather than the pod's own filesystem, deleting
`mysql-0` only destroys the pod — the volume and its data survive and get
reattached to the new pod.

---

## 7. HPA verification

```bash
kubectl get hpa -n capstone
```
```
NAME            REFERENCE              TARGETS      MINPODS   MAXPODS   REPLICAS
wordpress-hpa   Deployment/wordpress   <cpu>%/50%   2         10        2
```

---

## 8. Concepts-to-day mapping

| Concept | Day learned | Where it's used |
|---|---|---|
| Namespace | Day 52 | `capstone` namespace isolates the whole stack |
| Secret | Day 54–56 | `mysql-secret` holds all DB credentials |
| ConfigMap | Day 52 | `wordpress-config` holds DB host/name |
| PersistentVolumeClaim | Day 54–56 | `volumeClaimTemplates` in `mysql-statefulset.yaml` |
| StatefulSet | Day 54–56 | `mysql` StatefulSet, stable pod identity (`mysql-0`) |
| Headless Service | Day 54–56 | `mysql-service.yaml` (`clusterIP: None`) |
| Deployment | Day 52 | `wordpress` Deployment, 2 replicas |
| NodePort Service | Day 53 | `wordpress-service.yaml`, port `30080` |
| Resource requests/limits | Day 54–56 | Set on both the MySQL and WordPress containers |
| Liveness/Readiness probes | Day 57 | `/wp-login.php` probes on the WordPress Deployment |
| HorizontalPodAutoscaler | Day 58 | `wordpress-hpa`, 2–10 replicas at 50% CPU |
| Helm | Day 59 | Bitnami WordPress chart, deployed separately for comparison |

Twelve concepts, one deployment.

---

## 9. Reflection

**What was hardest:** Getting the deploy order right. `WORDPRESS_DB_HOST`
points at `mysql-0.mysql.capstone.svc.cluster.local`, a per-pod DNS record
that only exists once `mysql-0` is running behind the headless Service.
Applying the WordPress Deployment before MySQL was ready caused WordPress
to fail its DB connection on startup — which initially looked like a probe
misconfiguration but was really a timing issue between the two workloads.

**What clicked:** Watching `mysql-0` come back after
`kubectl delete pod mysql-0` and reattach the *same* PVC made the
pod-vs-storage separation concrete — the pod is disposable, the volume is
not.

**What I'd add for production:**
- **Probes on the MySQL StatefulSet.** `mysql-statefulset.yaml` currently
  has no liveness/readiness probe, so a hung MySQL process wouldn't be
  detected automatically.
- **Backups/snapshots** of the MySQL PVC — surviving a pod restart isn't
  the same as surviving loss of the underlying volume.
- **TLS via Ingress + cert-manager** instead of a bare NodePort.
- **A NetworkPolicy** restricting which pods can reach `mysql:3306`.
- **A PodDisruptionBudget** on the WordPress Deployment so node
  drains/upgrades don't take both replicas down at once.
- **Shared storage for `wp-content/uploads`** — with 2 WordPress replicas
  and no shared volume, an upload through one pod isn't visible on the
  other.

---
*Submitted as part of the 90 Days of DevOps challenge — `#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham`*
