# Day 57 – Resource Requests, Limits, and Probes

## Overview
Today's goal was to move from "Pods just run" to "Kubernetes knows how much a Pod
needs and how to tell if it's healthy." This covers `resources.requests`,
`resources.limits`, QoS classes, OOMKilled behavior, scheduler rejection on
unschedulable requests, and the three probe types (liveness, readiness, startup).

All manifests used below are in `manifests/`.

---

## Task 1: Resource Requests and Limits

**Manifest:** `manifests/1-pod-resources.yaml`

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "250m"
    memory: "256Mi"
```

```bash
kubectl apply -f manifests/1-pod-resources.yaml
kubectl describe pod resource-demo
```

Key sections in `describe pod` output:

```
Requests:
  cpu:        100m
  memory:     128Mi
Limits:
  cpu:        250m
  memory:     256Mi
QoS Class:    Burstable
```

- **Requests** = what the scheduler guarantees is available on the chosen node
  (used purely for *placement/scheduling* decisions).
- **Limits** = the hard ceiling the kubelet enforces at *runtime* (via cgroups).

### Verify: What QoS class does the Pod have?
**Burstable** — because `requests` are set lower than `limits`
(100m/128Mi < 250m/256Mi).

QoS class rules:
| Condition | QoS Class |
|---|---|
| `requests == limits` for every resource, on every container | Guaranteed |
| requests and limits set but not equal | Burstable |
| no requests/limits set at all | BestEffort |

*(Screenshot placeholder: `kubectl describe pod resource-demo` output)*

---

## Task 2: OOMKilled — Exceeding Memory Limits

**Manifest:** `manifests/2-pod-oomkilled.yaml`

Memory limit set to `100Mi`, but the container (using `polinux/stress`) tries to
allocate `200M`:

```yaml
command: ["stress"]
args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
```

```bash
kubectl apply -f manifests/2-pod-oomkilled.yaml
kubectl get pod oom-demo -w
kubectl describe pod oom-demo
```

Expected `describe pod` output:

```
State:          Terminated
  Reason:       OOMKilled
  Exit Code:    137
Last State:     Terminated
  Reason:       OOMKilled
  Exit Code:    137
```

- **CPU** is a *compressible* resource — exceeding the CPU limit results in
  **throttling**, not termination.
- **Memory** is an *incompressible* resource — the kernel cgroup OOM killer
  sends `SIGKILL` the moment the container tries to exceed its memory limit.
  There is no throttling option for memory.

### Verify: What exit code does an OOMKilled container have?
**Exit Code 137** = `128 + 9` (`SIGKILL` = signal 9). This is the standard Linux
convention (`128 + signal number`) and always shows up alongside
`Reason: OOMKilled` for memory-limit kills.

*(Screenshot placeholder: `kubectl describe pod oom-demo` showing OOMKilled/137)*

---

## Task 3: Pending Pod — Requesting Too Much

**Manifest:** `manifests/3-pod-pending.yaml`

```yaml
resources:
  requests:
    cpu: "100"
    memory: "128Gi"
```

```bash
kubectl apply -f manifests/3-pod-pending.yaml
kubectl get pod pending-demo
kubectl describe pod pending-demo
```

`kubectl get pod` shows `STATUS: Pending` indefinitely — no node in the cluster
has 100 full CPU cores and 128Gi of memory free/allocatable, so the scheduler
can never find a fit.

### Verify: What event message does the scheduler produce?
In the `Events` section of `kubectl describe pod`:

```
Warning  FailedScheduling  default-scheduler  0/2 nodes are available:
2 Insufficient cpu, 2 Insufficient memory.
preemption: 0/2 nodes are available: 2 No preemption victims found for
incoming pod.
```

The exact node counts vary with your cluster size, but the message always
follows the pattern `Insufficient <resource>` per node, produced by the
`default-scheduler`.

*(Screenshot placeholder: `kubectl describe pod pending-demo` Events section)*

---

## Task 4: Liveness Probe

**Manifest:** `manifests/4-pod-liveness.yaml`

The container creates `/tmp/healthy` on startup, sleeps 30s, then deletes it:

```yaml
args:
  - /bin/sh
  - -c
  - touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 600
livenessProbe:
  exec:
    command: ["cat", "/tmp/healthy"]
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 3
```

```bash
kubectl apply -f manifests/4-pod-liveness.yaml
kubectl get pod liveness-demo -w
kubectl describe pod liveness-demo
```

Timeline:
- 0–30s: `/tmp/healthy` exists → probe succeeds → container considered alive.
- 30s onward: file is gone → `cat` exits non-zero → probe fails.
- After **3 consecutive failures** (at `periodSeconds: 5`, that's ~15s of
  failing, so ~45s after the file was deleted) the kubelet restarts the
  container.
- `kubectl describe pod` Events show:
  ```
  Warning  Unhealthy  Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
  Normal   Killing    Container liveness-demo-ctr failed liveness probe, will be restarted
  ```

### Verify: How many times has the container restarted?
Check with:
```bash
kubectl get pod liveness-demo -o jsonpath='{.status.containerStatuses[0].restartCount}'
```
Each time the file goes missing and 3 probe failures accumulate, the
**RESTARTS** count (visible in `kubectl get pod`) increments by 1 and keeps
incrementing on every subsequent cycle (since the same startup script keeps
deleting the file 30s after each restart) — so the count keeps climbing (1, 2,
3…) the longer the Pod runs, following the standard exponential
`CrashLoopBackOff` restart-delay pattern once it starts failing repeatedly.

*(Screenshot placeholder: `kubectl get pod liveness-demo` showing RESTARTS column incrementing)*

---

## Task 5: Readiness Probe

**Manifest:** `manifests/5-pod-readiness.yaml`

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 3
```

```bash
kubectl apply -f manifests/5-pod-readiness.yaml
kubectl expose pod readiness-demo --port=80 --name=readiness-svc
kubectl get endpoints readiness-svc
```

Initially the Pod IP is listed as an endpoint (Pod is `1/1 READY`).

Break it:
```bash
kubectl exec readiness-demo -- rm /usr/share/nginx/html/index.html
```

After ~15s (3 × 5s failureThreshold):
```bash
kubectl get pod readiness-demo      # READY column shows 0/1
kubectl get endpoints readiness-svc # <none>
```

### Verify: When readiness failed, was the container restarted?
**No.** `RESTARTS` stays at `0`. The container process keeps running the
whole time — readiness failure only removes the Pod's IP from the Service's
Endpoints object so traffic stops being routed to it. This is the key
distinction from liveness: readiness manages **traffic**, liveness manages
**container lifecycle**.

*(Screenshot placeholder: `kubectl get pod` 0/1 READY + `kubectl get endpoints` empty + RESTARTS still 0)*

---

## Task 6: Startup Probe

**Manifest:** `manifests/6-pod-startup.yaml`

Container takes 20s to become ready:
```yaml
args:
  - /bin/sh
  - -c
  - sleep 20 && touch /tmp/started && sleep 600
startupProbe:
  exec:
    command: ["cat", "/tmp/started"]
  periodSeconds: 5
  failureThreshold: 12   # 12 x 5s = 60s budget
livenessProbe:
  exec:
    command: ["cat", "/tmp/started"]
  periodSeconds: 5
  failureThreshold: 3
```

While the `startupProbe` is running (and failing, because `/tmp/started`
doesn't exist yet), Kubernetes **disables** the liveness and readiness probes
entirely — so the slow-starting container isn't killed for "failing"
liveness checks it hasn't even had a chance to pass yet. Only once the
startup probe succeeds does the liveness probe take over.

### Verify: What would happen if `failureThreshold` were 2 instead of 12?
With `periodSeconds: 5` and `failureThreshold: 2`, the startup probe's total
budget would be only `2 × 5s = 10s`. Since the container needs 20s before
`/tmp/started` is created, the startup probe would **never succeed in time**
— it would fail twice (at ~5s and ~10s) before the file exists, and the
kubelet would treat startup as failed and **kill and restart the container**.
This would put the Pod into a permanent `CrashLoopBackOff`, because every
restart repeats the same 20s startup delay against the same 10s budget. This
is exactly why the startup probe's `periodSeconds × failureThreshold` budget
must comfortably exceed the container's real worst-case startup time.

*(Screenshot placeholder: `kubectl describe pod startup-demo` Events showing startup probe activity, and liveness probe only starting after success)*

---

## Task 7: Clean Up

```bash
kubectl delete pod resource-demo oom-demo pending-demo liveness-demo readiness-demo startup-demo
kubectl delete svc readiness-svc
```

---

## Summary: Requests vs Limits vs Probes

| Concept | Purpose | Enforced by | Failure behavior |
|---|---|---|---|
| `requests` | Scheduling — guaranteed minimum resources for placement | Scheduler | Pod stays `Pending` if no node can satisfy it |
| `limits` | Runtime ceiling on resource usage | Kubelet / cgroups | CPU: throttled. Memory: `OOMKilled` (exit 137) |
| `livenessProbe` | "Is this container still working?" | Kubelet | Failure → container **restarted** |
| `readinessProbe` | "Is this container ready to receive traffic?" | Kubelet + Endpoints controller | Failure → removed from Service **endpoints**, no restart |
| `startupProbe` | "Has this slow-starting container finished starting?" | Kubelet | While probing: liveness/readiness disabled. Failure → container **killed** (treated as startup failure) |

**Key takeaways:**
- CPU limits throttle; memory limits kill. Memory is incompressible, CPU is compressible.
- QoS class (`Guaranteed` / `Burstable` / `BestEffort`) is derived automatically
  from how requests/limits compare, and affects eviction priority under node
  pressure (BestEffort pods are evicted first).
- Liveness ≠ readiness: one heals the container, the other manages traffic —
  mixing them up (e.g., putting a slow-dependency check in a liveness probe)
  is a common cause of needless restart loops.
- Startup probes exist specifically to stop liveness probes from
  prematurely killing containers that are legitimately just slow to boot.

---

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
