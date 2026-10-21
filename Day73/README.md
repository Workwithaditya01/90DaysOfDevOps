# Day 73: Introduction to Observability and Prometheus

> Part of my **#90DaysOfDevOps** journey with TrainWithShubham.

Once infrastructure (Terraform), servers (Ansible) and containers (Docker) are running, the next question is: **how do I know they are healthy, and why did something break at 3 AM?**

Today I learned the three pillars of observability and set up **Prometheus** in Docker, ran my first PromQL queries, and added a sample app as a scrape target.

---

## Table of Contents

- [What I Built](#what-i-built)
- [Task 1: Understand Observability](#task-1-understand-observability)
- [Task 2: Set Up Prometheus with Docker](#task-2-set-up-prometheus-with-docker)
- [Task 3: Prometheus Concepts](#task-3-prometheus-concepts)
- [Task 4: PromQL Basics](#task-4-promql-basics)
- [Task 5: Sample App as a Scrape Target](#task-5-sample-app-as-a-scrape-target)
- [Task 6: Data Retention and Storage](#task-6-data-retention-and-storage)
- [Troubleshooting](#troubleshooting)
- [Key Takeaways](#key-takeaways)

---

## What I Built

- Prometheus running in a Docker container with a persistent volume
- A working `prometheus.yml` scraping Prometheus itself and a sample app
- Hands-on PromQL queries (instant vectors, range vectors, `rate()`, aggregation, filters, `topk`)
- An understanding of how Prometheus stores data and why volumes matter

**Tech used:** Docker, Docker Compose, Prometheus, PromQL

### Quick start

```bash
mkdir observability-stack && cd observability-stack
# add prometheus.yml and docker-compose.yml (shown below)
docker compose up -d
```

Then open `http://localhost:9090`.

---

## Task 1: Understand Observability

### Monitoring vs Observability

| | Monitoring | Observability |
|---|---|---|
| Tells you | **When** something is wrong | **Why** something is wrong |
| How | Alerts, thresholds | Explore, query, correlate |
| Analogy | The alarm on a heart monitor | Opening the full patient chart |

### The three pillars

| Pillar | What it is | Answers | Tools |
|---|---|---|---|
| **Metrics** | Numbers measured over time (CPU, request count, error rate) | **What** is broken | Prometheus, Datadog, CloudWatch |
| **Logs** | Timestamped text records of events | **Why** it broke | Loki, ELK Stack, Fluentd |
| **Traces** | The journey of one request across services | **Where** it broke | OpenTelemetry, Jaeger, Zipkin |

**Example:** users report slow checkout. Metrics show the error rate on `/checkout` spiked (what), logs show a database timeout (why), and traces show the payment service call took 12 seconds (where). Memory trick: **What, Why, Where = Metrics, Logs, Traces.**

### Architecture (Days 73-77)

```
[Your App] --> metrics --> [Prometheus] --> [Grafana Dashboards]
[Your App] --> logs    --> [Promtail]   --> [Loki] --> [Grafana]
[Your App] --> traces  --> [OTEL Collector] --> [Grafana/Debug]
[Host]     --> metrics --> [Node Exporter] --> [Prometheus]
[Docker]   --> metrics --> [cAdvisor] --> [Prometheus]
```

Apps and servers produce data, collectors carry it, storage keeps it, and Grafana is the screen I look at.

---

## Task 2: Set Up Prometheus with Docker

### `prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
```

### `docker-compose.yml`

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
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped

volumes:
  prometheus_data:
```

### Start and verify

```bash
docker compose up -d
```

Opened `http://localhost:9090`, then **Status > Targets** showed the `prometheus` target as **UP**.

---

## Task 3: Prometheus Concepts

- **Scrape target:** an endpoint Prometheus pulls metrics from at regular intervals (pull model).
- **Label:** a key-value pair that adds a dimension, e.g. `http_requests_total{method="GET", status="200"}`.
- **Time series:** a unique combination of metric name + labels.

| Metric type | Behavior | Example |
|---|---|---|
| **Counter** | Only goes up | Total requests served |
| **Gauge** | Goes up and down | Current memory, active connections |
| **Histogram** | Counts values in buckets | Request duration (<100ms, <500ms, <1s) |
| **Summary** | Like histogram, percentiles computed on the client | Client-side p99 latency |

### Queries I ran

**1. How many metrics is Prometheus collecting about itself?**

```promql
count({__name__=~".+"})
```

Returned `{}` with a single value. The empty braces mean `count()` aggregated everything into one series and dropped all labels. The value is the total number of time series Prometheus holds.

**2. Memory used by Prometheus**

```promql
process_resident_memory_bytes
```

Returned: `process_resident_memory_bytes{instance="localhost:9090", job="prometheus"}`

**3. Total HTTP requests to the Prometheus server**

```promql
prometheus_http_requests_total
```

Returned one series per handler/code, e.g. `prometheus_http_requests_total{code="200", handler="/", instance="localhost:9090", job="prometheus"}`

**4. Breakdown by handler**

```promql
prometheus_http_requests_total{handler="/api/v1/query"}
```

Returned: `prometheus_http_requests_total{code="200", handler="/api/v1/query", instance="localhost:9090", job="prometheus"}`

### Counter vs Gauge

A **counter** is a running total that only increases (it resets to zero only on restart), like a car's **odometer**. Example: `prometheus_http_requests_total`.

A **gauge** is a current reading that goes up and down, like a **speedometer**. Example: `process_resident_memory_bytes`.

---

## Task 4: PromQL Basics

| # | Type | Query | What it does |
|---|---|---|---|
| 1 | Instant vector | `up` | 1 (up) or 0 (down) per target |
| 2 | Range vector | `prometheus_http_requests_total[5m]` | All values from the last 5 minutes |
| 3 | Rate | `rate(prometheus_http_requests_total[5m])` | Per-second rate of a counter |
| 4 | Aggregation | `sum(rate(prometheus_http_requests_total[5m]))` | Sum across all label combinations |
| 5 | Label filter | `prometheus_http_requests_total{code!="200"}` | Only non-200 requests |
| 6 | Arithmetic | `process_resident_memory_bytes / 1024 / 1024` | Bytes to megabytes |
| 7 | Top-K | `topk(5, prometheus_http_requests_total)` | The 5 largest series |

### 1. Instant vector

```promql
up
```

Result: `prometheus` = 1, `notes-app` = 0 (after Task 5).

### 2. Range vector

```promql
prometheus_http_requests_total[5m]
```

Returns multiple timestamped values per series from the last 5 minutes.

### 3. Rate

```promql
rate(prometheus_http_requests_total[5m])
```

Returns the per-second request rate for each handler.

### 4. Aggregation

```promql
sum(rate(prometheus_http_requests_total[5m]))
```

Returns a single number: total requests per second.

### 5. Filter by label

```promql
prometheus_http_requests_total{code="200"}
prometheus_http_requests_total{code!="200"}
```

The first shows successful requests, the second shows only non-200 responses.

### 6. Arithmetic

```promql
process_resident_memory_bytes / 1024 / 1024
```

Result: **109.68 MB** of memory used by Prometheus.

### 7. Top-K

```promql
topk(5, prometheus_http_requests_total)
```

| Handler | Requests |
|---|---|
| `/metrics` | 103 |
| `/api/v1/notifications/live` | 54 |
| `/api/v1/query` | 21 |
| `/api/v1/query_range` | 8 |
| `/api/v1/label/:name/values` | lowest of the top 5 |

### Exercise: rate of non-200 requests over 5 minutes

```promql
rate(prometheus_http_requests_total{code!="200"}[5m])
```

For one total number, wrap it in `sum(...)`.

### Rules I learned

- `rate()` works only on **counters**, not gauges.
- Always `sum(rate(...))`, never `rate(sum(...))`. Rate first, then add.
- A counter alone says "5,000,000 requests ever". `rate()` turns that into "50 requests per second right now".

---

## Task 5: Sample App as a Scrape Target

### Updated `docker-compose.yml`

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
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped

  notes-app:
    image: trainwithshubham/notes-app:latest
    container_name: notes-app
    ports:
      - "8000:8000"
    restart: unless-stopped

volumes:
  prometheus_data:
```

### Updated `prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "notes-app"
    static_configs:
      - targets: ["notes-app:8000"]
```

The target is `notes-app:8000`, not `localhost`, because inside Docker containers reach each other by **service name**.

### Restart and generate traffic

```bash
docker compose up -d
docker compose restart prometheus   # make Prometheus re-read prometheus.yml
docker ps

curl http://localhost:8000
curl http://localhost:8000
curl http://localhost:8000
```

### Observation

`prometheus` is **UP**. `notes-app` is **DOWN** with a `404`. The app logs show why:

```
[21/Oct/2026 06:07:59] "GET / HTTP/1.1" 200 651
Not Found: /metrics
[21/Oct/2026 06:10:20] "GET /metrics HTTP/1.1" 404 2304
Not Found: /metrics
[21/Oct/2026 06:10:35] "GET /metrics HTTP/1.1" 404 2304
Not Found: /metrics
[21/Oct/2026 06:10:50] "GET /metrics HTTP/1.1" 404 2304
```

- My `curl` requests returned `200`, so the app is alive.
- The `/metrics` requests arrive exactly **15 seconds apart**, proving the **pull model** and `scrape_interval: 15s`.
- The `404` means the network works, but the app does not expose Prometheus metrics natively.
- This is why **exporters** (Node Exporter, cAdvisor, OTEL Collector) exist. They are coming in the next days.

---

## Task 6: Data Retention and Storage

### Disk usage

```bash
docker exec prometheus du -sh //prometheus
```

Output: `896.0K  /prometheus`

### Retention settings

Prometheus stores data in a local time-series database (TSDB). Default retention is **15 days**. It can be changed in the `command` section:

```yaml
command:
  - '--config.file=/etc/prometheus/prometheus.yml'
  - '--storage.tsdb.retention.time=30d'
  - '--storage.tsdb.retention.size=1GB'
```

### TSDB Status

Checked **Status > TSDB Status** for the number of series, chunks, label pairs, and top series by metric name.

### Answers

**What happens when retention is exceeded?**
Prometheus automatically deletes the oldest data blocks. Both limits are enforced, and whichever is reached first triggers the cleanup.

**Why is a volume mount important?**
Containers are disposable. Without a volume, recreating the container wipes all stored metrics. The `prometheus_data` volume keeps data on the host, so history survives restarts and container replacement.

---

## Troubleshooting

**Git Bash on Windows rewrites `/paths`.** Running `docker exec prometheus du -sh /prometheus` failed with:

```
du: C:/Program Files/Git/prometheus: No such file or directory
```

Git Bash (MINGW) converts Unix-style paths into Windows paths before Docker sees them. Fixes:

```bash
docker exec prometheus du -sh //prometheus                      # double slash
MSYS_NO_PATHCONV=1 docker exec prometheus du -sh /prometheus    # disable conversion
docker exec prometheus sh -c "du -sh /prometheus"               # run in a shell
```

---

## Key Takeaways

- Monitoring = alarm. Observability = investigation.
- Metrics (what), Logs (why), Traces (where).
- Prometheus **pulls** metrics from targets every 15 seconds.
- Counter = odometer, Gauge = speedometer, `rate()` turns an odometer into a speed.
- DOWN with 404 means the app is reachable but has no `/metrics` endpoint. Exporters fix that.
- A volume keeps Prometheus data alive when the container dies.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
