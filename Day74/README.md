# Day 74: Node Exporter, cAdvisor and Grafana Dashboards

Part of my **#90DaysOfDevOps** journey with TrainWithShubham.

A Docker Compose observability stack that monitors both the **host machine** and the **Docker containers** running on it, with **Grafana** dashboards on top of **Prometheus**.

> Full walkthrough, queries, screenshots and debugging notes: [day-74-exporters-grafana.md](./day-74-exporters-grafana.md)

---

## What this project does

On Day 73, Prometheus only monitored itself. This stack adds:

- **Node Exporter** for host metrics (CPU, memory, disk, network)
- **cAdvisor** for per-container metrics (CPU, memory, network)
- **Grafana** to turn raw PromQL into dashboards
- **YAML provisioning** so Grafana starts with its datasource already configured

## Architecture

```
 Host / Docker Desktop
 ┌──────────────────────────────────────────────────┐
 │  node-exporter :9100 ──┐                         │
 │  cadvisor      :8080 ──┼──► prometheus :9090 ──► grafana :3000
 │  prometheus    :9090 ──┘        (scrapes)         (dashboards)
 │  notes-app (from Day 73)                         │
 └──────────────────────────────────────────────────┘
```

| Service | Port | Role |
|---|---|---|
| `prometheus` | 9090 | Scrapes and stores metrics |
| `node-exporter` | 9100 | Host metrics (`node_*`) |
| `cadvisor` | 8080 | Container metrics (`container_*`) |
| `grafana` | 3000 | Dashboards and visualization |
| `notes-app` | Day 73 port | Sample app from Day 73 |

## Project structure

```
.
├── docker-compose.yml
├── prometheus.yml
├── day-74-exporters-grafana.md
└── grafana/
    └── provisioning/
        ├── datasources/
        │   └── datasources.yml
        └── dashboards/
```

## Prerequisites

- Docker and Docker Compose v2
- Day 73 project (Prometheus config and `notes-app`)
- Ports `3000`, `8080`, `9090` and `9100` free

## Quick start

```bash
# Start the whole stack
docker compose up -d

# Check that all 5 services are running
docker compose ps
```

| What | URL |
|---|---|
| Prometheus | http://localhost:9090 |
| Prometheus Targets | http://localhost:9090/targets |
| Node Exporter metrics | http://localhost:9100/metrics |
| cAdvisor UI | http://localhost:8080 |
| Grafana | http://localhost:3000 |

Grafana login: `admin` / `admin123` (learning only; use secrets in production).

## Key configuration

**Prometheus scrape targets** (`prometheus.yml`):

```yaml
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

**Auto-provisioned datasource** (`grafana/provisioning/datasources/datasources.yml`):

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

Containers reach each other by **service name** (`prometheus:9090`), never `localhost`.

## Dashboard: DevOps Observability Overview

| Panel | Type | PromQL |
|---|---|---|
| CPU Usage % | Gauge | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |
| Memory Usage % | Gauge | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100` |
| Container CPU Usage | Time series | `rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100` |
| Container Memory (MB) | Bar chart | `container_memory_usage_bytes{name!=""} / 1024 / 1024` |
| Disk Usage % | Stat | `(1 - node_filesystem_avail_bytes{mountpoint="/var/lib"} / node_filesystem_size_bytes{mountpoint="/var/lib"}) * 100` |

Community dashboards imported: **1860** (Node Exporter Full) and **193** (Docker monitoring).

## Node Exporter vs cAdvisor

| | Node Exporter | cAdvisor |
|---|---|---|
| Monitors | The host machine | Docker containers |
| Metric prefix | `node_` | `container_` |
| Answers | "Is the server healthy?" | "Which container is using the resources?" |

Use both together: Node Exporter shows *that* the host is under pressure, cAdvisor shows *which container* is causing it.

## Screenshots

**Prometheus targets (all UP)**

![Prometheus Targets](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/321767e9ef2b17183803e837cfc0e6a68ca21b59/Day74/Screenshots/prometheus%20up%20targer.png?raw=true)

**Custom Grafana dashboard**

![Custom Dashboard](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Grafana%20All%20Charts.png?raw=true)

**Node Exporter Full (ID 1860)**

![Node Exporter Full](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Node%20Export%20Dashboard.png?raw=true)

**cAdvisor UI**

![cAdvisor UI](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/cadvisor%20main%20page.png?raw=true)

**Provisioned datasource**

![Provisioned Datasource](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Default%20Data%20source.png?raw=true)

**All services running**

![Docker Compose PS](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/4ccedeac08bb1b219e8389c5a4413c92894acbbb/Day74/Screenshots/Docker%20compose%20ps.png?raw=true)

## Known issues (Docker Desktop with WSL2)

1. **Container queries with `{name!=""}` return empty.** Docker runs inside a VM, so cAdvisor often cannot attach container names. Workaround: query by `id`, e.g. `container_memory_usage_bytes{id=~"/docker/.*"}`.
2. **`mountpoint="/"` is not the real disk.** Use `mountpoint="/var/lib"` (Docker's data disk) instead. `/mnt/host/c` shows the Windows C: drive.
3. **Some Node Exporter Full panels are empty.** The WSL2 VM does not expose every hardware metric. This is expected.

## Key learnings

- Counters like `node_cpu_seconds_total` only increase, so wrap them in `rate()`.
- Node Exporter and cAdvisor answer different questions and work best together.
- Provisioning datasources via YAML makes Grafana setup repeatable and version controlled.
- Real environments differ, and debugging those differences is part of DevOps.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
