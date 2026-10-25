# Day 76: OpenTelemetry and Alerting

Part of the **#90DaysOfDevOps** challenge by TrainWithShubham.

Today I completed the observability stack by adding the third pillar, **traces**, using OpenTelemetry, and set up **alerting** with Prometheus and Grafana so the system notifies me when something goes wrong.

| Pillar | Tool | Status |
|--------|------|--------|
| Metrics | Prometheus, Node Exporter, cAdvisor, OTEL Collector | Done |
| Logs | Loki, Promtail | Done |
| Traces | OpenTelemetry Collector (OTLP) | Done (debug output) |
| Alerting | Prometheus rules, Grafana contact points and policies | Done |

---

## Architecture

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

## Services

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics storage, querying, alert rules |
| Node Exporter | 9100 | Host system metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Visualization and alerting |
| Loki | 3100 | Log storage |
| Promtail | 9080 | Log collection agent |
| OTEL Collector | 4317 / 4318 / 8889 | Telemetry collection (OTLP gRPC, HTTP, Prometheus exporter) |
| Notes App | 8000 | Sample application being monitored |

## Project Structure

```
.
├── docker-compose.yml
├── prometheus.yml
├── alert-rules.yml
├── otel-collector/
│   └── otel-collector-config.yml
├── loki/
│   └── loki-config.yml
├── promtail/
│   └── promtail-config.yml
├── grafana/
│   └── provisioning/
├── .env                      # SMTP password (not committed)
└── day-76-otel-alerting.md   # Detailed notes
```

## Quick Start

```bash
# 1. Start the full stack
docker compose up -d

# 2. Verify all 8 containers are running
docker compose ps

# 3. Validate the alert rules
docker exec prometheus promtool check rules /etc/prometheus/alert-rules.yml
```

| UI | URL |
|----|-----|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| Notes App | http://localhost:8000 |

---

## What I Did

### Task 1: Understood OpenTelemetry
- **OTEL** is a vendor-neutral framework for collecting metrics, logs, and traces. It is not a storage backend.
- The **Collector** has three parts: receivers (intake), processors (batching, filtering), exporters (output).
- **OTLP** is the standard protocol, over gRPC (4317) or HTTP (4318).
- A **trace** follows one request across services, and each step is a **span**.

### Task 2: Added the OTEL Collector
Configured OTLP receivers, a batch processor, and two exporters (`prometheus` on port 8889 and `debug`). Added the Collector to Docker Compose and as a Prometheus scrape target.

![Collector logs](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/otel-collector%20logs.png?raw=true)

![Prometheus targets](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/prometheus%20target%20page%20otel-collector.png?raw=true)

### Task 3: Sent test traces and metrics
Sent OTLP JSON to `localhost:4318` with curl. The trace appeared in the Collector debug logs, and the metric `test_requests_total` appeared in Prometheus.

```
curl -> OTEL Collector (OTLP receiver) -> Prometheus exporter -> Prometheus
```

![Trace in debug logs](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/otel-collector%20debug%20logs.png?raw=true)

![Metric in Prometheus](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/prometheus%20total%20request.png?raw=true)

### Task 4: Prometheus alerting rules
Created five rules in `alert-rules.yml`:

| Alert | Severity | Condition |
|-------|----------|-----------|
| HighCPUUsage | warning | CPU busy > 80% for 2m |
| HighMemoryUsage | warning | Memory used > 85% for 2m |
| ContainerDown | critical | `notes-app` series missing for 1m |
| TargetDown | critical | `up == 0` for 1m |
| HighDiskUsage | critical | Root disk > 90% for 5m |

Tested by stopping a scrape target and watching the alert go Pending then Firing.

![Prometheus rules](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/prometheus%20rules%20.png?raw=true)

![Alert firing](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/alert%20firing%20.png?raw=true)

### Task 5: Grafana alerts and notifications
Created a contact point (`DevOps Team`), an alert rule (`High Container Memory`), and a notification policy tree that routes `severity=critical` to a separate contact point.

![Notification policy tree](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/notification%20policy%20tree.png?raw=true)

![Alert notification email](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/firing%20email.png?raw=true)

**Prometheus alerts vs Grafana alerts**

| | Prometheus | Grafana |
|---|---|---|
| Defined in | YAML files | UI or provisioning |
| Data sources | Prometheus only | Many (including Loki) |
| Notifications | Needs Alertmanager | Built in |
| Best for | Alerts as code in git | Quick setup, mixed data sources |

### Task 6: Reviewed the full stack
Verified all 8 containers are running and mapped the three pipelines (metrics, logs, traces).

![docker compose ps](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/caa29edbded0ff70fab80692452ee621aa120808/Day76/screenshots/Docker%20compose%20ps.png?raw=true)

---

## Problems I Solved

| Problem | Cause | Fix |
|---------|-------|-----|
| `SMTP not configured` | `environment:` block was at the top level of `docker-compose.yml` | Moved the `GF_SMTP_*` variables inside the `grafana` service |
| `535 Username and Password not accepted` | Gmail rejects normal passwords for SMTP | Used a Google **app password** with 2-Step Verification |
| Secrets in compose file | Password would be committed to GitHub | Moved it to `.env` and added `.env` to `.gitignore` |

## Key Learnings

- OTEL is a collection framework, and the Collector decouples apps from backends.
- `for:` (the pending period) prevents alerts from firing on brief spikes.
- Prometheus evaluates alerts but needs Alertmanager to send notifications. Grafana has notifications built in.
- Compose environment variables must be inside the service that needs them.
- Never commit secrets. Use a `.env` file.

## Next Steps

- Add **Grafana Tempo** or **Jaeger** so traces are stored and searchable instead of only printed.
- Add **Alertmanager** for Prometheus-native notifications.
- Instrument the notes app with an OpenTelemetry SDK.

## Full Notes

See [`day-76-otel-alerting.md`](./day-76-otel-alerting.md) for the detailed task-by-task documentation, including all configs and explanations.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
