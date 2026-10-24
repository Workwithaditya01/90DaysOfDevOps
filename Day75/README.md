# Day 75 -- Log Management with Loki and Promtail

> Metrics tell you **what** is broken. Logs tell you **why**.

Part of my **#90DaysOfDevOps** challenge. On Day 74 I built the metrics pipeline (Prometheus, Node Exporter, cAdvisor, Grafana). Today I added the second pillar of observability, **logs**, with Grafana Loki and Promtail, and correlated both in a single Grafana instance.

📄 **Full write-up with every config explained:** [day-75-loki-promtail.md](./day-75-loki-promtail.md)

---

## What I Built

- ✅ **Loki** running as the log storage backend
- ✅ **Promtail** collecting Docker container logs and shipping them to Loki
- ✅ **Loki** added as a Grafana datasource (provisioned as code)
- ✅ **LogQL** queries running in Grafana Explore
- ✅ **Metrics and logs side by side** in one dashboard and in Explore split view

## Architecture

```
[Docker Containers]
       |
       | (write JSON logs to /var/lib/docker/containers/)
       v
  [Promtail]      reads log files, adds labels, pushes to Loki
       |
       v
    [Loki]        stores logs, indexes labels only
       |
       v
   [Grafana]      queries Loki with LogQL, shows logs next to metrics
       |
       v
   [You]
```

| Component | Role | Analogy |
|---|---|---|
| Docker containers | Write stdout/stderr as JSON files on the host | Source of the packages |
| Promtail | Reads files, attaches labels, pushes to Loki | Delivery driver |
| Loki | Stores log chunks, indexes labels | Warehouse |
| Grafana | Queries with LogQL and visualises | Search window |

## Tech Stack

| Tool | Port | Purpose |
|---|---|---|
| Loki | 3100 | Log storage and query backend |
| Promtail | 9080 | Log collection agent |
| Grafana | 3000 | Dashboards and Explore |
| Prometheus | 9090 | Metrics (from Day 74) |
| Node Exporter | 9100 | Host metrics (from Day 74) |
| cAdvisor | 8080 | Container metrics (from Day 74) |

## Folder Structure

```
Day75/
├── README.md                    <- you are here
├── day-75-loki-promtail.md      <- full documentation
└── Screenshot/                  <- proof of work
```

The working stack itself lives next to the Day 74 `docker-compose.yml`:

```
observability-stack/
├── docker-compose.yml           <- loki, promtail, loki_data added
├── loki/
│   └── loki-config.yml
├── promtail/
│   └── promtail-config.yml
└── grafana/provisioning/datasources/
    └── datasources.yml          <- Loki datasource added
```

---

## Quick Start

```bash
# 1. Start Loki and verify
docker compose up -d loki
curl http://localhost:3100/ready          # -> ready

# 2. Start the rest of the stack (Promtail included)
docker compose up -d

# 3. Generate some logs
for i in $(seq 1 20); do curl -s http://localhost:8000 > /dev/null; done

# 4. Confirm logs reached Loki
curl -G -s "http://localhost:3100/loki/api/v1/labels"    # should include "job"
```

Then open Grafana at `http://localhost:3000` > **Explore** > select **Loki**.

---

## Key Configuration

### Promtail (final version, with Docker service discovery)

```yaml
scrape_configs:
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container_name'
      - target_label: 'job'
        replacement: 'docker'
    pipeline_stages:
      - docker: {}
```

The starter config reads files by path and only produces `filename`, `job`, and `stream` labels. Switching to `docker_sd_configs` adds the `container_name` label that the queries rely on.

### Grafana datasource (provisioned)

```yaml
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
```

Full Loki, Promtail, datasource, and Compose files with line-by-line explanations are in [day-75-loki-promtail.md](./day-75-loki-promtail.md).

---

## LogQL Cheat Sheet

| Goal | Query |
|---|---|
| All Docker logs | `{job="docker"}` |
| One container | `{container_name="notes-app"}` |
| Lines containing "error" | `{job="docker"} \|= "error"` |
| Case-insensitive search | `{job="docker"} \|~ "(?i)error"` |
| Exclude noise | `{job="docker"} != "health"` |
| HTTP 4xx/5xx | `{job="docker"} \|~ "status=[45][0-9]{2}"` |
| Lines per 5 minutes | `count_over_time({job="docker"}[5m])` |
| Lines per second | `rate({job="docker"}[5m])` |
| Top 5 chattiest containers | `topk(5, sum by (container_name) (rate({job="docker"}[5m])))` |
| Errors per minute (notes-app) | `sum(count_over_time({container_name="notes-app"} \|~ "(?i)error" [1m]))` |

**Tip:** the stream selector `{...}` is fast (label-based); filters like `|=` scan text afterwards. Always narrow with labels first.

---

## Screenshots

### Loki is ready
![Loki ready](./Screenshot/curl%203100.png)

### All services running
![docker compose ps](./Screenshot/dockerps%20loki%20promtail.png)

### Promtail targets
![Promtail targets](./Screenshot/promtail%20page.png)

### Grafana datasources (Prometheus and Loki)
![Grafana data sources](./Screenshot/task%204%20loki%20Data%20source.png)

### Loki datasource connected
![Loki test successful](./Screenshot/loki%20data%20source%20connected%20successfully.png)

### Grafana Explore showing Docker logs from Loki
![Explore showing Loki logs](./Screenshot/5.1%20All%20Docker%20Logs.png)

### Top containers by log volume
![Top containers by log volume](./Screenshot/5.8%20top%20containers%20by%20volumn.png)

### Container Logs panel on the dashboard
![Dashboard with Container Logs panel](./Screenshot/Container%20logs%20grafana%20dashboard.png)

### Metrics and logs side by side
![Metrics and logs side by side](./Screenshot/6%20correlation%20.png)

---

## Problems I Hit and How I Fixed Them

| Problem | Cause | Fix |
|---|---|---|
| `timestamp too old` errors in Promtail logs | Promtail tried to push weeks of old history; Loki rejects lines older than 7 days by default | Harmless (recent lines still arrive). Optionally set `reject_old_samples_max_age: 2160h` in `limits_config` |
| `localhost:9080/targets` "site can't be reached" | Port 9080 was only open inside the Docker network | Added `ports: - "9080:9080"` to the Promtail service |
| `container_name` label missing | Starter config scrapes files by path and has no container metadata | Switched to `docker_sd_configs` with a relabel rule |

**Debugging tip:** don't read logs top to bottom, filter by severity first:

```bash
docker compose logs promtail 2>&1 | grep -E "level=(error|warn)"
```

---

## Loki vs ELK at a Glance

| | Loki | ELK |
|---|---|---|
| Indexing | Labels only | Full text |
| Cost and resources | Low | High |
| Operations | Simple | Complex |
| Broad text search | Slower | Very fast |
| Best for | Container/Kubernetes logs, Prometheus + Grafana teams | Full-text search, SIEM, complex analytics |

---

## Key Takeaways

- **Metrics + logs = full observability.** Metrics show when and how much; logs explain why.
- **Loki indexes labels, not text.** Cheap and simple, at the cost of slower broad text search.
- **Keep label cardinality low.** Use `container_name` and `job`; never `user_id` or `request_id`.
- **Use service names inside Docker networks** (`loki`, `prometheus`), never `localhost`.
- **Provision datasources as code** so a fresh Grafana comes up fully configured.
- **Correlate in one place.** Selecting a CPU spike and instantly seeing the logs from that moment cuts time to diagnosis.

---

## Learn in Public

> Added the second pillar of observability today -- logs. Set up Loki and Promtail to collect all Docker container logs, queried them with LogQL in Grafana, and correlated metrics with logs side by side. When a CPU spike happens, I can now instantly see the exact log lines from that moment.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham

---

## Reference

- Task source: TrainWithShubham 90 Days of DevOps
- Reference repo: [observability-for-devops](https://github.com/LondheShubham153/observability-for-devops) (see the `loki/` and `promtail/` directories)
