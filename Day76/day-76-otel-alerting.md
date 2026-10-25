# Day 76: OpenTelemetry and Alerting

Today I added the third pillar of observability (traces) using OpenTelemetry, and set up alerting with both Prometheus and Grafana, so the stack now covers **metrics, logs, and traces** and actively notifies me when something goes wrong.

---

## Task 1: Understand OpenTelemetry

### What is OpenTelemetry (OTEL)?
A vendor-neutral, open-source framework for generating, collecting, and exporting telemetry data (metrics, logs, traces). It is **not a backend**. It collects data and ships it to backends such as Prometheus, Jaeger, Loki, or Datadog.

| Type | Answers | Example |
|------|---------|---------|
| Metrics | How much / how many? | 500 orders per minute |
| Logs | What happened? | "Payment failed for order #123" |
| Traces | Where did the time go? | Order spent 2s in payment, 15 min cooking |

### What is the OTEL Collector?
A standalone service that receives, processes, and exports telemetry. It has three pipeline components:

```
Receivers  ->  Processors  ->  Exporters
(intake)       (transform)     (send out)
```

- **Receivers:** accept data (OTLP, Prometheus, Jaeger formats)
- **Processors:** transform data (batching, filtering, sampling)
- **Exporters:** send data to backends (Prometheus, debug console, Jaeger)

**Analogy:** a post office. Receivers are the intake counter, processors are the sorting room, exporters are the delivery trucks.

### What is OTLP?
The OpenTelemetry Protocol, the standard wire format for telemetry.
- gRPC on port **4317** (fast, binary)
- HTTP on port **4318** (simple, works with curl)

### What are distributed traces?
A **trace** follows one request through multiple services. Each step is a **span**.

A span has: trace ID, span ID, parent span ID, start time, duration, attributes.

```
User request -> API Gateway (span 1) -> Auth Service (span 2) -> Database (span 3)
```

---

## Task 2: Add the OpenTelemetry Collector

### `otel-collector/otel-collector-config.yml`

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  debug:
    verbosity: detailed

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

**Explanation**
- **Receivers:** accepts OTLP over gRPC (4317) and HTTP (4318). `0.0.0.0` means it listens on all interfaces so other containers and the host can reach it.
- **Processors:** `batch` groups data before exporting, reducing overhead.
- **Exporters:** the `prometheus` exporter exposes metrics on port 8889 for Prometheus to scrape. The `debug` exporter prints data to the container console.
- **Pipelines:** metrics go to Prometheus, traces and logs go to debug output. In production, traces would go to Jaeger or Tempo.

### docker-compose service

```yaml
  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    container_name: otel-collector
    ports:
      - "4317:4317"   # OTLP gRPC
      - "4318:4318"   # OTLP HTTP
      - "8889:8889"   # Prometheus exporter
    volumes:
      - ./otel-collector/otel-collector-config.yml:/etc/otelcol-contrib/config.yaml
    restart: unless-stopped
```

### Prometheus scrape job

```yaml
  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```

### Verification

```bash
docker compose up -d
docker logs otel-collector 2>&1 | tail -5
```

**Collector logs showing it started:**

![Collector startup logs](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/otel-collector%20logs.png)

**Prometheus Targets page with `otel-collector` UP:**

![Prometheus targets](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/prometheus%20target%20page%20otel-collector.png)

---

## Task 3: Send Test Traces to the Collector

### Send a trace

```bash
curl -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
    "resourceSpans": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "my-test-service" }
        }]
      },
      "scopeSpans": [{
        "spans": [{
          "traceId": "5b8efff798038103d269b633813fc60c",
          "spanId": "eee19b7ec3c1b174",
          "name": "test-span",
          "kind": 1,
          "startTimeUnixNano": "1544712660000000000",
          "endTimeUnixNano": "1544712661000000000",
          "attributes": [
            { "key": "http.method", "value": { "stringValue": "GET" } },
            { "key": "http.status_code", "value": { "intValue": "200" } }
          ]
        }]
      }]
    }]
  }'
```

**Expected response:** `{"partialSuccess":{}}` (data accepted).

### View the trace in the debug logs

```bash
docker logs otel-collector 2>&1 | grep -B 8 -A 10 "test-span"
```

**Screenshot: trace appearing in the collector debug logs**

![Trace in collector debug logs](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/otel-collector%20debug%20logs.png)

### Send a metric

```bash
curl -X POST http://localhost:4318/v1/metrics \
  -H "Content-Type: application/json" \
  -d '{
    "resourceMetrics": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "my-test-service" }
        }]
      },
      "scopeMetrics": [{
        "metrics": [{
          "name": "test_requests_total",
          "sum": {
            "dataPoints": [{
              "asInt": "42",
              "startTimeUnixNano": "1544712660000000000",
              "timeUnixNano": "1544712661000000000"
            }],
            "aggregationTemporality": 2,
            "isMonotonic": true
          }
        }]
      }]
    }]
  }'
```

Check the Collector's exporter endpoint directly:

```bash
curl http://localhost:8889/metrics | grep test_requests_total
```

Then query in Prometheus:

```promql
test_requests_total
```

**Screenshot: metric visible in Prometheus (value 42)**

![test_requests_total in Prometheus](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/prometheus%20total%20request.png)

**Metric path:** curl -> OTEL Collector (OTLP receiver) -> Prometheus exporter (:8889) -> Prometheus scrape -> query.

---

## Task 4: Prometheus Alerting Rules

### `alert-rules.yml`

```yaml
groups:
  - name: system-alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage has been above 80% for more than 2 minutes. Current value: {{ $value }}%"

      - alert: HighMemoryUsage
        expr: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 > 85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85%. Current value: {{ $value }}%"

      - alert: ContainerDown
        expr: absent(container_last_seen{name="notes-app"})
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container is down"
          description: "The notes-app container has not been seen for over 1 minute"

      - alert: TargetDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Scrape target is down"
          description: "{{ $labels.job }} target {{ $labels.instance }} is unreachable"

      - alert: HighDiskUsage
        expr: (1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space running low"
          description: "Root filesystem usage is above 90%. Current value: {{ $value }}%"
```

### What each alert does

| Alert | Severity | For | Explanation |
|-------|----------|-----|-------------|
| HighCPUUsage | warning | 2m | Takes the idle CPU rate, averages it, and subtracts from 100 to get busy %. Fires above 80%. |
| HighMemoryUsage | warning | 2m | Computes used memory as `1 - available/total`. Fires above 85%. |
| ContainerDown | critical | 1m | `absent()` returns a result only when the `notes-app` series disappears completely. |
| TargetDown | critical | 1m | `up` is 1 for a successful scrape, 0 for a failed one. This rule watches every target. |
| HighDiskUsage | critical | 5m | Same idea as memory, for the `/` filesystem. Longer `for` since disk usage changes slowly. |

**Field meanings:** `expr` is the PromQL condition, `for` is the pending period that avoids flapping, `labels` carry routing metadata, `annotations` hold human-readable text.

**Alert states:** Inactive -> Pending -> Firing.

### Wiring it in

`prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/alert-rules.yml

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
  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```

`docker-compose.yml` (Prometheus volumes):

```yaml
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert-rules.yml:/etc/prometheus/alert-rules.yml
      - prometheus_data:/prometheus
```

```bash
docker compose up -d prometheus
docker exec prometheus promtool check rules /etc/prometheus/alert-rules.yml
```

**Screenshot: Status > Rules showing all 5 rules**

![Prometheus rules](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/prometheus%20rules%20.png)

**Screenshot: Alerts page with alert states (all inactive)**

![Prometheus alerts inactive](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/prometheus%20system%20alerts.png)

### Testing an alert

`TargetDown` only fires for containers that are scrape targets, so I stopped node-exporter:

```bash
docker compose stop node-exporter
# wait 1-2 minutes
docker compose start node-exporter
```

**Screenshot: Alerts page with TargetDown Pending/Firing**

![Prometheus alert firing](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/alert%20firing%20.png)

> Note: Prometheus shows alerts in its UI but cannot send notifications without Alertmanager. Grafana alerting (Task 5) handles notifications.

---

## Task 5: Grafana Alerts

### 1. Contact point
Alerting > Contact points > Add contact point

- Name: `DevOps Team`
- Integration: Email (SMTP configured via `GF_SMTP_*` environment variables inside the `grafana` service)

**Issue faced:** "SMTP not configured". The `environment:` block was at the top level of the compose file instead of inside the `grafana` service. Moving it into the service fixed it.

**Second issue:** `535 Username and Password not accepted`. Gmail requires an **app password** (with 2-Step Verification on), not the normal account password. Secrets are kept in a `.env` file and referenced as `${SMTP_PASSWORD}`.

**Screenshot: contact point test notification**

![Contact point test](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/Grafana%20testing%20.png)

### 2. Alert rule
Alerting > Alert rules > New alert rule

| Setting | Value |
|---------|-------|
| Name | High Container Memory |
| Query | `container_memory_usage_bytes{name="notes-app"} / 1024 / 1024` |
| Reduce | Last |
| Condition | IS ABOVE 100 |
| Evaluation | every 1m, pending 2m |
| Label | severity = warning |
| Contact point | DevOps Team |


### 3. Notification policy
- Default policy -> `DevOps Team`
- Nested policy: `severity = critical` -> `On-Call Critical`

```
Default policy  ->  DevOps Team
 +- severity = critical  ->  On-Call Critical
```

**Screenshot: notification policies tree**

![Notification policies](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/notification%20policy%20tree.png)

### 4. Alert state and notification
I temporarily lowered the threshold to see Normal -> Pending -> Firing, then restored it to 100.

**Screenshot: rule in Firing state**

![Grafana alert firing](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/alert%20firing%20.png)

**Screenshot: received notification (email or webhook)**

![Notification received](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/firing%20email.png)

### Prometheus alerts vs Grafana alerts

| | Prometheus alerts | Grafana alerts |
|---|---|---|
| Defined in | YAML rule files | Grafana UI or provisioning |
| Data sources | Prometheus only | Many (Prometheus, Loki, SQL, cloud) |
| Notifications | Needs Alertmanager | Built in (contact points and policies) |
| Version control | Easy (plain files in git) | Harder via UI |
| Setup effort | Higher | Lower |

**When to use which**
- **Prometheus + Alertmanager:** alerts as code, reviewed in git, independent of Grafana; standard in production Kubernetes setups.
- **Grafana alerting:** quick setup, alerts on Loki logs or mixed data sources, one place for dashboards and alerts.

---

## Task 6: Full Stack Architecture

```
                    METRICS PIPELINE
[Node Exporter] -----> [Prometheus] -----> [Grafana Dashboards]
[cAdvisor] ----------> [Prometheus] -----> [Grafana Dashboards]
[OTEL Collector:8889]> [Prometheus] -----> [Grafana Dashboards]
                                    -----> [Alert Rules -> Notifications]

                    LOGS PIPELINE
[Docker Containers] -> [Promtail] -> [Loki] -> [Grafana Explore/Dashboards]

                    TRACES PIPELINE
[curl/App OTLP] -----> [OTEL Collector] -> [Debug Output / Future: Jaeger/Tempo]
```

### Services running

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics storage and querying |
| Node Exporter | 9100 | Host system metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Visualization and alerting |
| Loki | 3100 | Log storage |
| Promtail | 9080 | Log collection agent |
| OTEL Collector | 4317/4318/8889 | Telemetry collection |
| Notes App | 8000 | Sample application |

```bash
docker compose ps
```

**Screenshot: all 8 containers running**

![docker compose ps](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/Docker%20compose%20ps.png)

---

## Key Learnings

- OTEL is a collection framework, not a storage backend. The Collector decouples apps from backends.
- OTLP over HTTP (4318) is easy to test with curl; apps normally use SDKs.
- `for:` (pending period) prevents alerts from firing on brief spikes.
- Prometheus evaluates alerts but needs Alertmanager to notify; Grafana has notifications built in.
- Docker Compose environment variables must be inside the service that needs them.
- Never commit secrets: use a `.env` file and add it to `.gitignore`.

## Next Steps
Add Grafana Tempo or Jaeger as a trace backend so traces are stored and searchable instead of only printed to debug output.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
