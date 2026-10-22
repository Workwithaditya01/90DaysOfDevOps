# Day 74 -- Node Exporter, cAdvisor, and Grafana Dashboards

## Overview

On Day 73 Prometheus was only monitoring itself. Today I extended the stack so it monitors the **host machine** (Node Exporter) and the **Docker containers** (cAdvisor), and added **Grafana** to visualize everything in dashboards instead of raw PromQL.

**Stack at the end of the day:**

| Service | Port | Role |
|---|---|---|
| `prometheus` | 9090 | Collects and stores metrics |
| `node-exporter` | 9100 | Host metrics (CPU, memory, disk, network) |
| `cadvisor` | 8080 | Per-container metrics |
| `grafana` | 3000 | Dashboards and visualization |
| `notes-app` | (Day 73 port) | Sample application from Day 73 |

**Environment note:** I ran this on Docker Desktop with WSL2 (Windows). This caused two differences from the task text, documented in the "Issues I Hit" section.

---

## Final `docker-compose.yml`

> Replace the `prometheus` and `notes-app` blocks with your exact Day 73 versions if they differ.

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    privileged: true
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    devices:
      - /dev/kmsg
    restart: unless-stopped

  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped

  notes-app:
    # Keep your Day 73 notes-app configuration here
    image: <your-notes-app-image>
    container_name: notes-app
    ports:
      - "<host-port>:<container-port>"
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
```

### Why the volume mounts?

**Node Exporter**
- `/proc` -- kernel and process info (CPU stats, memory info)
- `/sys` -- hardware and driver details
- `/` -- filesystem usage (disk space)
- All mounted read-only (`ro`) because it only reads, never modifies.

**cAdvisor**
- Docker socket / `/var/run` -- lets cAdvisor discover and query running containers
- `/sys` -- kernel-level container stats (cgroups)
- `/var/lib/docker/` -- container filesystem information

---

## Final `prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "cadvisor"
    static_configs:
      - targets: ["cadvisor:8080"]
```

Targets use the **service name** (e.g. `node-exporter:9100`) instead of `localhost`, because inside the Prometheus container `localhost` means Prometheus itself. Containers on the same Compose network reach each other by service name.

---

## Task 1: Node Exporter (Host Metrics)

**Goal:** Let Prometheus collect host-level metrics (CPU, RAM, disk, network).

**Commands used:**

```bash
docker compose up -d
curl http://localhost:9100/metrics | head -20
```

**Verification:** `node-exporter` shows as **UP** on the Prometheus Targets page.

### PromQL queries (host)

```promql
# CPU: idle time per core (counter, so wrap in rate() for usage)
node_cpu_seconds_total{mode="idle"}

# Memory: total vs available
node_memory_MemTotal_bytes
node_memory_MemAvailable_bytes

# Memory usage percentage
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

# Disk: filesystem usage percentage
(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100

# Network: bytes received per second
rate(node_network_receive_bytes_total[5m])
```

| Query | What it shows |
|---|---|
| `node_cpu_seconds_total{mode="idle"}` | Seconds each core has spent idle (only ever increases) |
| Memory usage % | Share of RAM currently in use |
| Disk usage % | How full each filesystem is |
| `rate(node_network_receive_bytes_total[5m])` | Incoming network throughput per interface |

### Screenshots (Task 1)

**Memory usage query in Prometheus** (`(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100`):

![Memory Usage Query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/321767e9ef2b17183803e837cfc0e6a68ca21b59/Day74/Screenshots/Memory%20Usage.png)

**Prometheus Targets page** (all targets UP, take this one last after cAdvisor is running):

![Prometheus Targets](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/321767e9ef2b17183803e837cfc0e6a68ca21b59/Day74/Screenshots/prometheus%20up%20targer.png)

---

## Task 2: cAdvisor (Container Metrics)

**Goal:** Let Prometheus collect per-container CPU, memory and network metrics.

**Verification:** cAdvisor UI at `http://localhost:8080` and `cadvisor` showing **UP** in Targets.

### PromQL queries (containers)

```promql
# CPU usage per container (in cores)
rate(container_cpu_usage_seconds_total{name!=""}[5m])

# Memory usage per container
container_memory_usage_bytes{name!=""}

# Network received bytes per container
rate(container_network_receive_bytes_total{name!=""}[5m])

# Which container uses the most memory?
topk(3, container_memory_usage_bytes{name!=""})
```

`{name!=""}` removes aggregated/system-level entries so only named containers are shown.

> On my Docker Desktop/WSL2 setup the `name` label was missing, so I used an `id`-based filter as a workaround. See "Issues I Hit".

### Screenshots (Task 2)

**cAdvisor web UI** (`http://localhost:8080`, Docker Containers view):

![cAdvisor UI](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/cadvisor%20main%20page.png)

**Container metrics query in Prometheus** (e.g. `topk(3, container_memory_usage_bytes{name!=""})` or the `id=~` workaround):

![Container Memory Query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/top%203%20container.png)
![Container Memory graph](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/top%203%20container%20memory%20usage%20graph.png)

### Node Exporter vs cAdvisor

| | **Node Exporter** | **cAdvisor** |
|---|---|---|
| **Monitors** | The host machine (VM/server) | Docker containers |
| **Metric prefix** | `node_` | `container_` |
| **Port** | 9100 | 8080 |
| **Answers** | "Is the server healthy?" | "Which container is using the resources?" |
| **Example metrics** | `node_cpu_seconds_total`, `node_filesystem_avail_bytes` | `container_cpu_usage_seconds_total`, `container_memory_usage_bytes` |

**When to use which:**
- **Node Exporter:** capacity planning, disk-full alerts, "is the server overloaded?"
- **cAdvisor:** finding a noisy container, setting container memory limits, debugging a restarting container.
- **Use both together:** Node Exporter tells me *that* the host is under pressure; cAdvisor tells me *which container* is causing it. Analogy: Node Exporter is the electricity meter for the whole building, cAdvisor is the meter on each flat.

---

## Task 3: Grafana Setup

Added the `grafana` service and the `grafana_data` named volume (so dashboards survive container restarts), then logged in at `http://localhost:3000` with `admin` / `admin123`.

**Prometheus datasource:**
1. Connections > Data sources > Add data source > Prometheus
2. URL: `http://prometheus:9090`
3. Save & test -> "Successfully queried the Prometheus API"

**Why `http://prometheus:9090` and not `localhost`?** Grafana runs in its own container, where `localhost` is Grafana itself. Containers on the same Docker network find each other by service name.

> Note: `admin123` is fine for learning. In production, use a secret instead of a hardcoded password.

### Screenshot (Task 3)

**Grafana datasource "Save & test" success message:**

![Grafana Datasource Success](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Grafana%20connected%20successfully.png)

---

## Task 4: Custom Dashboard -- "DevOps Observability Overview"

| # | Panel | Visualization | PromQL |
|---|---|---|---|
| 1 | CPU Usage % | Gauge | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |
| 2 | Memory Usage % | Gauge | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100` |
| 3 | Container CPU Usage | Time series | `rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100` |
| 4 | Container Memory (MB) | Bar chart | `container_memory_usage_bytes{name!=""} / 1024 / 1024` |
| 5 | Disk Usage % | Stat | `(1 - node_filesystem_avail_bytes{mountpoint="/var/lib"} / node_filesystem_size_bytes{mountpoint="/var/lib"}) * 100` |

**Thresholds used:**
- CPU gauge: green < 60, yellow < 80, red >= 80 (CPU spikes are normal, so red starts later)
- Memory gauge: green < 70, yellow < 90, red >= 90
- Disk stat: green < 70, yellow < 85, red >= 85 (disk fills slowly and outages are severe, so I warn earlier)

**Why each query works:**
- CPU: Node Exporter exposes idle time per core. `rate()` converts the counter to "fraction of time idle", `avg()` merges all cores, and `100 - idle%` gives usage.
- Memory: `MemAvailable` is the memory the kernel can hand out without swapping, so `1 - available/total` is real usage.
- Container CPU: `rate()` on the cumulative CPU-seconds counter gives cores used; multiplying by 100 gives percent of one core.

### Screenshot: DevOps Observability Overview

![Custom Grafana Dashboard](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Grafana%20All%20Charts.png)

---

## Task 5: Auto-Provision Datasources with YAML

**Folder structure:**

```
.
├── docker-compose.yml
├── prometheus.yml
└── grafana/
    └── provisioning/
        ├── datasources/
        │   └── datasources.yml
        └── dashboards/
```

**`grafana/provisioning/datasources/datasources.yml`:**

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
```

**Mounted into Grafana:**

```yaml
volumes:
  - grafana_data:/var/lib/grafana
  - ./grafana/provisioning:/etc/grafana/provisioning
```

**Applied with:**

```bash
docker compose up -d grafana
```

### Screenshot (Task 5)

**Provisioned Prometheus datasource** (Connections > Data sources, showing the default and provisioned badges):

![Provisioned Datasource](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Default%20Data%20source.png)

### How provisioning works

On startup Grafana reads every YAML file under `/etc/grafana/provisioning/datasources/`, creates or updates the datasources they describe, and marks them as **provisioned**.

- `access: proxy` -- Grafana's server makes the requests to Prometheus (not the browser), which is why the container name works.
- `isDefault: true` -- pre-selected datasource for new panels.
- `editable: false` -- locks the datasource in the UI to prevent config drift.

### Why provisioning beats the UI

| Manual (UI) | Provisioned (YAML) |
|---|---|
| Click-through steps nobody remembers | Config is written down in a file |
| Not version controlled | Committed to Git with history and review |
| Hard to reproduce on a new server | Same result on every `docker compose up` |
| Anyone can edit it and cause drift | `editable: false` prevents accidental changes |
| Slow across many environments | Identical in dev, staging and prod |

Provisioning turns Grafana setup into **Infrastructure as Code**: repeatable, reviewable and recoverable. If the Grafana server dies, redeploying restores the datasources in seconds.

---

## Task 6: Community Dashboards

- **Dashboard 1860 (Node Exporter Full):** Dashboards > New > Import > ID `1860` > select Prometheus > Import. It covers CPU, memory, disk, network and more, all built on the same `node_` metrics I queried manually.
- **Dashboard 193 (Docker monitoring via cAdvisor):** imported the same way. Some panels depend on the `name` label (see below).

### Screenshot: Node Exporter Full (ID 1860)

![Node Exporter Full](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Node%20Export%20Dashboard.png)

### Verify all services are running

```bash
docker compose ps
```

All five services (`prometheus`, `node-exporter`, `cadvisor`, `grafana`, `notes-app`) show as running.

![Docker Compose PS](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Docker%20compose%20ps.png)

---


## Issues I Hit (and How I Fixed Them)

### 1. Container queries with `{name!=""}` returned "Empty query result"

- **Cause:** On Docker Desktop/WSL2, Docker runs inside a VM, so cAdvisor often cannot map cgroups to container names and the `name` label is missing.
- **Debugging steps:**
  1. Confirmed the `cadvisor` target was UP.
  2. Ran `container_memory_usage_bytes` without a filter to confirm data existed.
  3. Inspected labels and saw `id` but no `name`.
- **Workaround:** Query by `id` instead, e.g. `container_memory_usage_bytes{id=~"/docker/.*"}`, and use `{{id}}` as the legend. I also made cAdvisor more complete (`privileged: true`, `/` and `/var/run` mounts, `/dev/kmsg`).

### 2. Disk panel: `mountpoint="/"` was not the right mount

- **Cause:** On Docker Desktop/WSL2 the `/` mountpoint is not exposed the usual way, and Node Exporter showed odd internal mounts like `/parent-distro/init`, which is a tiny WSL init filesystem.
- **Debugging steps:** Ran `node_filesystem_size_bytes` and compared devices. `/dev/sdd` was the large Docker data disk (about 974 GB free), while `/dev/sde` was a tiny internal distro (about 56 MB free) that would have shown about 99% usage.
- **Fix:** Used `mountpoint="/var/lib"` (Docker's data disk). Optionally, `/mnt/host/c` shows the Windows C: drive.

### 3. Other notes

- Some Node Exporter Full panels (hardware/disk details) may be empty on WSL2 because the VM does not expose every metric. This is expected.
- If a manual datasource and the provisioned one share a name, delete the manual one so the provisioned one is the single source of truth.

---

## Key Learnings

- Node Exporter answers "is the host healthy?" and cAdvisor answers "which container is the culprit?". Used together they speed up incident diagnosis.
- Counters (like `node_cpu_seconds_total`) only increase, so they need `rate()` to be meaningful.
- Inside Docker networks, use service names (`prometheus:9090`), never `localhost`.
- Provisioning datasources via YAML makes the observability stack reproducible and version controlled.
- Real environments differ (Docker Desktop vs native Linux), and debugging those differences is part of the job.

---

## Submission

```bash
mkdir -p 2026/day-74
cp day-74-exporters-grafana.md 2026/day-74/
cp -r screenshots 2026/day-74/
git add 2026/day-74/
git commit -m "Add Day 74: Node Exporter, cAdvisor and Grafana dashboards"
git push origin main
```

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
