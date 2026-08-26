# Day 58 – Metrics Server and Horizontal Pod Autoscaler (HPA)

## 1. What is the Metrics Server, and why does HPA need it?

The **Metrics Server** is a cluster add-on that collects real-time resource usage
(CPU and memory) from every node's **kubelet** via the Summary API, aggregates
it, and exposes it through the **Kubernetes Metrics API**
(`metrics.k8s.io`). It does **not** store historical data — it only holds the
most recent sample (refreshed roughly every 15 seconds) and is meant for
autoscaling decisions and `kubectl top`, not long-term monitoring
(that's what Prometheus/Grafana are for).

The **HorizontalPodAutoscaler (HPA)** controller needs to know how much CPU
(or memory) pods are *actually* using right now, compared to what they
*requested*, in order to decide whether to scale up or down. Without the
Metrics Server running, there is no source for that live usage data, so the
HPA has nothing to calculate against — `kubectl get hpa` will show
`TARGETS: <unknown>/50%` forever and no scaling will happen.

In short:
- **Metrics Server** = the data source (current CPU/memory usage per pod/node)
- **HPA** = the decision maker (reads that data every 15s and adjusts replica count)

## 2. How HPA calculates desired replicas

HPA polls the Metrics API every 15 seconds and applies this formula:

```
desiredReplicas = ceil( currentReplicas * ( currentMetricValue / desiredMetricValue ) )
```

Example: if a Deployment has 4 replicas, each requesting 200m CPU (target
utilization 50%), and current average usage is 400m per pod (i.e. 200%
utilization):

```
desiredReplicas = ceil( 4 * (200% / 50%) ) = ceil(4 * 4) = 16
```

Important behavior notes:
- HPA only scales resources that have `resources.requests` set — utilization
  percentage is meaningless without a request baseline.
- **Scale-up** is fast and responsive (default: can react almost immediately,
  limited only by policies you define).
- **Scale-down** is deliberately slow — a default **5-minute (300s)
  stabilization window** is used to avoid "flapping" (rapid scale up/down
  cycles caused by noisy, short-lived metric spikes).
- HPA never scales below `minReplicas` or above `maxReplicas`, regardless of
  the formula's output.

## 3. `autoscaling/v1` vs `autoscaling/v2`

| Feature | `autoscaling/v1` | `autoscaling/v2` |
|---|---|---|
| Metrics supported | CPU utilization only | CPU, memory, custom metrics, external metrics |
| Multiple metrics at once | No | Yes (scales on whichever metric demands the most replicas) |
| Scaling `behavior` (custom stabilization windows, scale-up/down policies) | No | Yes |
| Created via | `kubectl autoscale` (imperative) | YAML manifest (declarative) — recommended for real workloads |
| Status detail | Minimal | Detailed per-metric status and conditions |

`kubectl autoscale deployment ... --cpu-percent=50 --min=1 --max=10` actually
creates a `v2` object under the hood on modern clusters, but it can only
configure a single CPU-utilization metric — it can't set custom `behavior`
blocks or add memory/custom metrics. For anything beyond the simplest case,
write the HPA as YAML using `autoscaling/v2`.

## 4. Lab Walkthrough Summary

### Task 1 — Install Metrics Server
```bash
kubectl get pods -n kube-system | grep metrics-server
minikube addons enable metrics-server        # Minikube
# OR
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
On local clusters (self-signed kubelet certs), patched with:
```bash
--kubelet-insecure-tls
```

**Verify:** `kubectl top nodes`
> _Screenshot: node CPU/memory usage here_

### Task 2 — Explore `kubectl top`
```bash
kubectl top nodes
kubectl top pods -A
kubectl top pods -A --sort-by=cpu
```
`kubectl top` = **live usage** pulled from the Metrics Server.
`kubectl describe pod` = **configured** requests/limits. These are two
different concepts — usage can be above or below the configured request.

**Verify:** highest CPU-consuming pod at the time of the snapshot.
> _Screenshot: `kubectl top pods -A --sort-by=cpu` here_

### Task 3 — php-apache Deployment + Service
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
          limits:
            cpu: 500m
```
```bash
kubectl apply -f php-apache-deploy.yaml
kubectl expose deployment php-apache --port=80
```
**Verify:** `kubectl top pod -l run=php-apache` → baseline idle CPU (near 0m).

### Task 4 — Imperative HPA
```bash
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl get hpa
kubectl describe hpa php-apache
```
**Verify:** `TARGETS` shows `<unknown>/50%` immediately after creation, then
resolves to something like `0%/50%` once the Metrics Server reports data
(~30s).

### Task 5 — Load Test
```bash
kubectl run load-generator --image=busybox:1.36 --restart=Never \
  -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
kubectl get hpa php-apache --watch
```
> _Screenshot: HPA replica count climbing under load_

Over 1–3 minutes, CPU utilization climbs past 50%, HPA increases replicas
(observed scaling e.g. 1 → 4+ replicas depending on cluster CPU capacity),
then CPU/replica count stabilizes.

```bash
kubectl delete pod load-generator
```
Scale-down back to `minReplicas` takes up to 5 minutes due to the
stabilization window — this is expected and doesn't need to be waited out.

**Verify:** peak replica count reached under load.

### Task 6 — Declarative HPA (`autoscaling/v2`)
```bash
kubectl delete hpa php-apache
```
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
```
```bash
kubectl apply -f php-apache-hpa.yaml
kubectl describe hpa php-apache
```

**What the `behavior` section controls:**
- `scaleUp.stabilizationWindowSeconds: 0` — react immediately to CPU spikes,
  no delay before scaling up.
- `scaleUp.policies` — limits *how fast* replicas can be added (here, up to
  100% more replicas every 15 seconds).
- `scaleDown.stabilizationWindowSeconds: 300` — waits 5 minutes of
  consistently low usage before scaling down, preventing flapping from
  temporary dips.
- `scaleDown.policies` — limits scale-down to 50% of current replicas per
  60-second window, so it ramps down gradually rather than dropping straight
  to `minReplicas`.

> _Screenshot: `kubectl describe hpa php-apache` events section_

### Task 7 — Cleanup
```bash
kubectl delete hpa php-apache
kubectl delete svc php-apache
kubectl delete deployment php-apache
kubectl delete pod load-generator --ignore-not-found
```
Metrics Server was left installed, as instructed.

## 5. Key Takeaways
- HPA is useless without `resources.requests` on the target pods.
- Metrics Server ≠ Prometheus: it's a lightweight, in-memory, short-retention
  source built specifically for scheduling/autoscaling decisions.
- Scale-up is fast by design; scale-down is intentionally conservative.
- `autoscaling/v2` is the practical default for any real-world HPA — `v1` is
  fine only for the simplest CPU-only, no-behavior-tuning case.

---
`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
