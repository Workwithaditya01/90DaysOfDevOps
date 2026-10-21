# Day 73: Introduction to Observability and Prometheus

Once infrastructure (Terraform), servers (Ansible) and containers (Docker) are running, the next question is: **how do I know they are healthy, and why did something break at 3 AM?** Today I learned the three pillars of observability and set up Prometheus in Docker.

**Screenshots folder:** all images are stored in `screenshots/` next to this file.

---

## Task 1: Understand Observability

### 1. Observability vs Monitoring

| | Monitoring | Observability |
|---|---|---|
| Tells you | **When** something is wrong | **Why** something is wrong |
| How | Alerts, thresholds | Explore, query, correlate |
| Analogy | The alarm on a heart monitor | Opening the full patient chart |

### 2. The three pillars (in my own words)

| Pillar | What it is | Tools |
|---|---|---|
| **Metrics** | Numbers measured over time (CPU, request count, error rate) | Prometheus, Datadog, CloudWatch |
| **Logs** | Timestamped text records of events (app output, errors) | Loki, ELK Stack, Fluentd |
| **Traces** | The journey of a single request across services | OpenTelemetry, Jaeger, Zipkin |

### 3. Why all three?

- **Metrics tell me WHAT is broken**, e.g. high error rate on `/api/users`.
- **Logs tell me WHY it broke**, e.g. a stack trace showing a database timeout.
- **Traces tell me WHERE it broke**, e.g. the payment service call took 12 seconds.

Without all three I am guessing. Memory trick: **What, Why, Where = Metrics, Logs, Traces.**

### 4. Architecture I will build over Days 73-77

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

### Step 1: Project directory

```bash
mkdir observability-stack && cd observability-stack
```

### Step 2: `prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
```

Prometheus scrapes its own metrics every 15 seconds.

### Step 3: `docker-compose.yml`

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

### Step 4: Start Prometheus

```bash
docker compose up -d
```

Opened `http://localhost:9090` and the Prometheus web UI loaded.

**Screenshot: Prometheus UI**

![Prometheus UI](screenshots/task2-prometheus-ui.png)

**Verify:** Status > Targets shows one target, `prometheus`, with state **UP**.

**Screenshot: Targets page (one target UP)**

![Targets with one target UP](screenshots/task2-targets-one-up.png)

---

## Task 3: Understand Prometheus Concepts

- **Scrape target:** an endpoint Prometheus pulls metrics from at regular intervals (pull model).
- **Label:** a key-value pair that adds a dimension, e.g. `http_requests_total{method="GET", status="200"}`.
- **Time series:** a unique combination of metric name + labels. Change one label and it is a different series.

### Metric types

| Type | Behavior | Example |
|---|---|---|
| **Counter** | Only goes up | Total requests served, total errors |
| **Gauge** | Goes up and down | Current memory, active connections |
| **Histogram** | Counts values in buckets | Request duration (<100ms, <500ms, <1s) |
| **Summary** | Like histogram, percentiles calculated on the client | Client-side p99 latency |

### Queries I ran at `http://localhost:9090/graph`

**1. How many metrics is Prometheus collecting about itself?**

```promql
count({__name__=~".+"})
```

Result: {}_

![count query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/3.1.png)

**2. How much memory is Prometheus using?**

```promql
process_resident_memory_bytes
```

Result: process_resident_memory_bytes{instance="localhost:9090", job="prometheus"}

![memory query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/3.2.png)

**3. Total HTTP requests to the Prometheus server**

```promql
prometheus_http_requests_total
```

Result: prometheus_http_requests_total{code="200", handler="/", instance="localhost:9090", job="prometheus"}

![http requests query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/3.3.png)

**4. Breakdown by handler**

```promql
prometheus_http_requests_total{handler="/api/v1/query"}
```

Result: prometheus_http_requests_total{code="200", handler="/api/v1/query", instance="localhost:9090", job="prometheus"}

![handler query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/3.4.png)

### Counter vs Gauge

A **counter** is a running total that only increases (it resets to zero only on restart), like a car's **odometer**. Real-world example: `prometheus_http_requests_total`, the total number of requests served.

A **gauge** is a current reading that can go up and down, like a **speedometer**. Real-world example: `process_resident_memory_bytes`, the memory in use right now.

---

## Task 4: Learn PromQL Basics

PromQL is how I ask questions about my metrics.

| # | Type | Query | What it does |
|---|---|---|---|
| 1 | Instant vector | `up` | 1 (up) or 0 (down) for each target |
| 2 | Range vector | `prometheus_http_requests_total[5m]` | All values from the last 5 minutes |
| 3 | Rate | `rate(prometheus_http_requests_total[5m])` | Per-second rate of a counter |
| 4 | Aggregation | `sum(rate(prometheus_http_requests_total[5m]))` | Sum across all label combinations |
| 5 | Label filter | `prometheus_http_requests_total{code!="200"}` | Only non-200 requests |
| 6 | Arithmetic | `process_resident_memory_bytes / 1024 / 1024` | Bytes to megabytes |
| 7 | Top-K | `topk(5, prometheus_http_requests_total)` | The 5 largest series |

### 1. Instant vector: `up`

```promql
up
```

Result: `prometheus` = 1, `notes-app` = 0 (after Task 5).

![up query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/up%20query.png)

### 2. Range vector

```promql
prometheus_http_requests_total[5m]
```

Result: _multiple timestamped values per series from the last 5 minutes._

![range vector](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/4.2.png)

### 3. Rate

```promql
rate(prometheus_http_requests_total[5m])
```

Result: _per-second request rate for each handler._

![rate query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/4.3.png)

### 4. Aggregation

```promql
sum(rate(prometheus_http_requests_total[5m]))
```

Result: _a single number for the total requests per second._

![sum rate query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/4.4.png)

### 5. Filter by label

```promql
prometheus_http_requests_total{code="200"}
prometheus_http_requests_total{code!="200"}
```

Result: _the first shows successful requests, the second shows only non-200 responses._

![label filter](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/4.5.1.png)
![label filter](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/4.5.2.png)

### 6. Arithmetic

```promql
process_resident_memory_bytes / 1024 / 1024
```

Result: 109.68359375

![arithmetic query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/4.6.png)

### 7. Top-K

```promql
topk(5, prometheus_http_requests_total)
```

Result: prometheus_http_requests_total{code="200", handler="/metrics", instance="localhost:9090", job="prometheus"}	103
prometheus_http_requests_total{code="200", handler="/api/v1/notifications/live", instance="localhost:9090", job="prometheus"}	54
prometheus_http_requests_total{code="200", handler="/api/v1/query", instance="localhost:9090", job="prometheus"}	21
prometheus_http_requests_total{code="200", handler="/api/v1/query_range", instance="localhost:9090", job="prometheus"}	8
prometheus_http_requests_total{code="200", handler="/api/v1/label/:name/values", instance="localhost:9090", job="prometheus"} 

![topk query](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/4.7.png)


### Rules I learned

- `rate()` works only on **counters**, not gauges.
- Always `sum(rate(...))`, never `rate(sum(...))`. Rate first, then add.
- A counter alone says "5,000,000 requests ever". `rate()` turns that into "50 requests per second right now".

---

## Task 5: Add a Sample Application as a Scrape Target

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

The target is `notes-app:8000`, not `localhost`, because inside Docker containers find each other by **service name**.

### Restart the stack and generate traffic

```bash
docker compose up -d
docker compose restart prometheus   # make Prometheus re-read prometheus.yml
docker ps

curl http://localhost:8000
curl http://localhost:8000
curl http://localhost:8000
```

**Screenshot: `docker ps` with both containers running**

![docker ps](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/docker%20ps.png)

**Screenshot: Targets page with two targets**

![Targets with two targets](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/target%20page.png)

### Observation

`prometheus` is **UP**. `notes-app` is **DOWN** with a `404`. The app logs explain why:

```
[21/Oct/2026 06:07:59] "GET / HTTP/1.1" 200 651
Not Found: /metrics
[21/Oct/2026 06:10:20] "GET /metrics HTTP/1.1" 404 2304
Not Found: /metrics
[21/Oct/2026 06:10:35] "GET /metrics HTTP/1.1" 404 2304
Not Found: /metrics
[21/Oct/2026 06:10:50] "GET /metrics HTTP/1.1" 404 2304
```

What this taught me:

- My `curl` requests returned `200`, so the app is alive.
- The `/metrics` requests arrive exactly **15 seconds apart**, which proves the **pull model** and `scrape_interval: 15s`.
- The `404` means the network works (Prometheus reached the app by name), but the app does not expose Prometheus metrics natively.
- This is why **exporters** (Node Exporter, cAdvisor, OTEL Collector) exist. They will be used in the coming days.

**Screenshot: app logs**

![notes-app logs](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/docker%20logs.png)

---

## Task 6: Explore Data Retention and Storage

### 1. Disk usage

```bash
docker exec prometheus du -sh //prometheus
```

Output: 896.0K  /prometheus

![disk usage](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/docker%20exec%20prometheus.png)

**Git Bash note:** running `docker exec prometheus du -sh /prometheus` in Git Bash on Windows failed with:

```
du: C:/Program Files/Git/prometheus: No such file or directory
```

Git Bash (MINGW) rewrites Unix-style paths into Windows paths before Docker sees them. Fixes:

```bash
docker exec prometheus du -sh //prometheus                      # double slash
MSYS_NO_PATHCONV=1 docker exec prometheus du -sh /prometheus    # disable conversion
docker exec prometheus sh -c "du -sh /prometheus"               # run in a shell
```

### 2. Retention settings

Prometheus stores data in a local time-series database (TSDB). Default retention is **15 days**. It can be changed in the `command` section:

```yaml
command:
  - '--config.file=/etc/prometheus/prometheus.yml'
  - '--storage.tsdb.retention.time=30d'
  - '--storage.tsdb.retention.size=1GB'
```

### 3. TSDB Status

Opened **Status > TSDB Status** to see the number of series, chunks, label pairs, and the top series by metric name.

![TSDB status](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/50d7fe36a505bd8aa1b40f704a7c892cfc92134a/Day73/Screenshots/TSDB%20status.png)

### Documentation answers

**What happens when retention is exceeded?**
Prometheus automatically deletes the oldest data blocks. It enforces both limits (time and size), and whichever is reached first triggers the cleanup.

**Why is a volume mount important for Prometheus data?**
Containers are disposable. Without a volume, deleting or recreating the container wipes all stored metrics. The `prometheus_data` volume keeps the data on the host, so history survives restarts and container replacement.

---

## Key Takeaways

- Monitoring = alarm. Observability = investigation.
- Metrics (what), Logs (why), Traces (where).
- Prometheus **pulls** metrics from targets every 15 seconds.
- Counter = odometer, Gauge = speedometer, `rate()` turns an odometer into a speed.
- DOWN with 404 means the app is reachable but has no `/metrics` endpoint. Exporters fix that.
- A volume keeps Prometheus data alive when the container dies.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
