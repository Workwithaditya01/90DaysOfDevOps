# Day 75 -- Log Management with Loki and Promtail

> Metrics tell you **what** is broken. Logs tell you **why**.
> Yesterday I built the metrics pipeline with Prometheus, Node Exporter, cAdvisor, and Grafana. Today I added the second pillar of observability: **logs**, using Grafana Loki and Promtail.

## Expected Output

- [x] Loki running as a log storage backend
- [x] Promtail collecting Docker container logs and shipping them to Loki
- [x] Loki added as a datasource in Grafana
- [x] LogQL queries running in Grafana Explore
- [x] A markdown file: `day-75-loki-promtail.md`

---

## Task 1: Understand the Logging Pipeline

### Architecture diagram

```
[Docker Containers]
       |
       | (write JSON logs to /var/lib/docker/containers/)
       v
  [Promtail]
       |
       | (reads log files, adds labels, pushes to Loki)
       v
    [Loki]
       |
       | (stores logs, indexes by labels)
       v
   [Grafana]
       |
       | (queries Loki with LogQL, displays logs)
       v
   [You]
```

| Component | Role | Analogy |
|---|---|---|
| Docker containers | Write stdout/stderr as JSON files on the host | Source of the packages |
| Promtail | Reads log files, attaches labels, pushes to Loki | Delivery driver |
| Loki | Stores log chunks and indexes labels | Warehouse |
| Grafana | Queries Loki with LogQL and displays results | Search window |

### Key differences from the ELK stack

- Loki does **not** index the full text of logs. It only indexes labels (container name, job, filename).
- This makes Loki much cheaper to run and simpler to operate.
- Think of it as "Prometheus, but for logs" (same label-based approach).

### Document: Why does Loki only index labels instead of full text? What is the trade-off?

**Why:**
- A full-text index can be as large as the logs themselves, so skipping it greatly cuts storage and memory cost.
- It is simpler to operate than an Elasticsearch cluster (no shard tuning); Loki can run as a single binary.
- It reuses the Prometheus label model, so the same mental model works for metrics and logs.

**Trade-off:**
- Searching arbitrary text across a long time range is slower, because Loki must scan every chunk matched by the label selector.
- Advanced full-text features (fuzzy search, relevance ranking, deep aggregations) are better in Elasticsearch.

**Practical rule:** narrow with labels first, then filter by text. `{container_name="notes-app"} |= "error"` is fast because labels cut the data down before the text filter runs.

**Label cardinality:** keep it low. `container_name` and `job` are good labels. `user_id` or `request_id` would create thousands of tiny streams and hurt performance, so they belong inside the log line.

---

## Task 2: Add Loki to the Stack

### Loki configuration -- `loki/loki-config.yml`

```bash
mkdir -p loki
```

```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory
  replication_factor: 1
  path_prefix: /loki

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  filesystem:
    directory: /loki/chunks
```

### What this config does

| Setting | Explanation |
|---|---|
| `auth_enabled: false` | Single-tenant mode, no authentication needed. |
| `http_listen_port: 3100` | Port where Loki receives logs from Promtail and answers queries from Grafana. |
| `ring.kvstore.store: inmemory` | Instances coordinate in memory. Enough for a single instance. |
| `replication_factor: 1` | Each log line is stored once (production would use 3). |
| `path_prefix: /loki` | Base folder for Loki data, mounted to a Docker volume. |
| `store: tsdb` | Uses Loki's time-series database for the label index. |
| `object_store: filesystem` | Stores log chunks on local disk (production usually uses S3/GCS). |
| `schema: v13` | Current storage schema version. |
| `index.period: 24h` | New index file every day, which makes retention easier. |
| `filesystem.directory` | Exact folder for chunk files. |

### Loki service in `docker-compose.yml`

```yaml
  loki:
    image: grafana/loki:latest
    container_name: loki
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yml:/etc/loki/loki-config.yml
      - loki_data:/loki
    command: -config.file=/etc/loki/loki-config.yml
    restart: unless-stopped
```

```yaml
volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

`loki_data:/loki` is a named volume so logs survive `docker compose down`.

### Start and verify

```bash
docker compose up -d loki
curl http://localhost:3100/ready
```

Expected output: `ready` (Loki waits ~15 seconds after startup before reporting ready).

> **📸 Screenshot 1:** Terminal showing `curl http://localhost:3100/ready` returning `ready`.
>
> ![Loki ready](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/51b078150c0ad97132ba67de178055ae46a33f9b/Day75/Screenshot/curl%203100.png)

---

## Task 3: Add Promtail to Collect Container Logs

### Promtail configuration -- `promtail/promtail-config.yml`

```bash
mkdir -p promtail
```

**Final version (with Docker service discovery):**

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

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

**Starter version from the task (for comparison):**

```yaml
scrape_configs:
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*-json.log
    pipeline_stages:
      - docker: {}
```

The starter version only produces the labels `filename`, `job`, and `stream`. There is no `container_name` label, so queries like `{container_name="notes-app"}` return nothing. I switched to `docker_sd_configs` to get it.

### What this config does

| Setting | Explanation |
|---|---|
| `positions` | Bookmark of which log lines were already shipped. After a restart Promtail resumes; deleting it re-reads all logs. |
| `clients.url` | Where to send logs (Loki push endpoint). Uses the Compose service name `loki`, not `localhost`. |
| `docker_sd_configs` | Asks Docker (via the socket) for running containers and their metadata. |
| `relabel_configs` (container_name) | Turns Docker's `/notes-app` into the label `container_name="notes-app"`. |
| `relabel_configs` (job) | Adds the static label `job="docker"`. |
| `pipeline_stages: docker: {}` | Parses the Docker JSON format and extracts the timestamp, stream (stdout/stderr), and the log message. |
| `__path__` (starter version) | Glob pattern to find Docker JSON log files on the host. |

### Promtail service in `docker-compose.yml`

```yaml
  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    ports:
      - "9080:9080"
    volumes:
      - ./promtail/promtail-config.yml:/etc/promtail/promtail-config.yml
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    command: -config.file=/etc/promtail/promtail-config.yml
    restart: unless-stopped
```

### Why these volume mounts?

| Mount | Reason |
|---|---|
| `/var/lib/docker/containers:...:ro` | Where Docker stores container log files. Read-only because Promtail only needs to read. |
| `/var/run/docker.sock` | Lets Promtail discover container metadata (names, labels). |
| `ports: "9080:9080"` | Only added so I can open the `/targets` debug page in my browser. Log shipping does not need it. |

### Restart the stack and generate logs

```bash
docker compose up -d
for i in $(seq 1 20); do curl -s http://localhost:8000 > /dev/null; done
```

### Verify

```bash
docker compose ps
docker compose logs promtail
curl -G -s "http://localhost:3100/loki/api/v1/labels"
```

If the labels response includes `"job"`, logs are arriving in Loki.

> **📸 Screenshot 2:** `docker compose ps` showing all services running, including `loki` and `promtail`.
>
> ![docker compose ps](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/51b078150c0ad97132ba67de178055ae46a33f9b/Day75/Screenshot/dockerps%20loki%20promtail.png)

> **📸 Screenshot 3:** Promtail targets page at `http://localhost:9080/targets`.
>
> ![Promtail targets](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/51b078150c0ad97132ba67de178055ae46a33f9b/Day75/Screenshot/promtail%20page.png)

### Problems I hit

**1. `timestamp too old` errors in the Promtail logs**

```
level=error ... msg="final error sending batch" status=400
... has timestamp too old: 2026-08-06T04:55:46Z, oldest acceptable timestamp is: 2026-10-17T04:06:40Z
```

- **Cause:** Promtail had no saved position, so it tried to push the full history of containers that had been running for weeks. Loki rejects lines older than 7 days by default.
- **Impact:** Harmless. Recent lines were accepted; only old history was dropped.
- **Optional fix:** add to `loki-config.yml`:

  ```yaml
  limits_config:
    reject_old_samples: true
    reject_old_samples_max_age: 2160h   # 90 days
  ```

- **How I found it:** filter by severity instead of reading everything:

  ```bash
  docker compose logs promtail 2>&1 | grep -E "level=(error|warn)"
  ```

**2. `http://localhost:9080/targets` said "site can't be reached"**

- **Cause:** Promtail listened on 9080 only inside the Docker network. No `ports:` mapping existed.
- **Fix:** added `ports: - "9080:9080"` and ran `docker compose up -d promtail`.

---

## Task 4: Add Loki as a Grafana Datasource

### Option A -- Provisioned via YAML (used)

File: `grafana/provisioning/datasources/datasources.yml`

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
```

```bash
docker compose restart grafana
```

| Setting | Explanation |
|---|---|
| `access: proxy` | The Grafana server (not my browser) calls Loki, so the Docker-internal hostname works. |
| `url: http://loki:3100` | Uses the service name, not `localhost`. |
| `isDefault: true` | Prometheus remains the pre-selected datasource. |
| `editable: false` | The YAML stays the single source of truth ("configuration as code"). |

Result: two datasources in Grafana, **Prometheus** and **Loki**.

> **📸 Screenshot 4:** Grafana **Connections > Data sources** showing both Prometheus and Loki.
>
> ![Grafana data sources](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/51b078150c0ad97132ba67de178055ae46a33f9b/Day75/Screenshot/task%204%20loki%20Data%20source.png)

> **📸 Screenshot 5:** Loki datasource with the green "Data source successfully connected" message.
>
> ![Loki test successful](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/51b078150c0ad97132ba67de178055ae46a33f9b/Day75/Screenshot/loki%20data%20source%20connected%20successfully.png)

---

## Task 5: Query Logs with LogQL

Every LogQL query has a **stream selector** `{...}` (picks which logs, label-based and fast) and optional **filters** (pick which lines, text scan).

**How to run:** Grafana > **Explore** (compass icon) > select **Loki** > switch the editor to **Code** > paste the query > **Run query** (or Shift+Enter). Time range: **Last 1 hour**.

> **📸 Screenshot 6 (required):** Grafana Explore with Loki selected, showing log lines.
>
> ![Explore showing Loki logs](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/51b078150c0ad97132ba67de178055ae46a33f9b/Day75/Screenshot/5.1%20All%20Docker%20Logs.png)

### The queries

| # | Query | Purpose |
|---|---|---|
| 1 | `{job="docker"}` | All Docker container logs |
| 2 | `{container_name="notes-app"}` | Logs from one container |
| 3 | `{job="docker"} \|= "error"` | Lines containing "error" (case-sensitive) |
| 4 | `{job="docker"} != "health"` | Exclude health-check noise |
| 5 | `{job="docker"} \|~ "status=[45]\\d{2}"` | Regex for HTTP 4xx/5xx status codes |
| 6 | `count_over_time({job="docker"}[5m])` | Log lines per 5-minute window |
| 7 | `rate({job="docker"}[5m])` | Log lines per second |
| 8 | `topk(5, sum by (container_name) (rate({job="docker"}[5m])))` | Top 5 containers by log volume |

Notes: `|=` is case-sensitive, so use `|~ "(?i)error"` for case-insensitive matching. In the editor I use `[0-9]` instead of `\d` to avoid escaping problems, and I adapt the status-code regex to my app's real log format (for example `|~ "\" [45][0-9]{2}"` for access-log lines such as `"GET /x HTTP/1.1" 404`).

### Five LogQL queries I ran and what they returned

**Query 1**
```logql
{job="docker"}
```
Returned: `TODO: e.g. "Log lines from N containers (notes-app, prometheus, grafana, ...)"`

**Query 2**
```logql
{container_name="notes-app"}
```
Returned: `TODO: e.g. "20 lines, all GET / requests from the notes app"`

**Query 3**
```logql
{job="docker"} |~ "(?i)error"
```
Returned: `TODO: e.g. "N lines mentioning error from ..." or "no results, no errors present"`

**Query 4**
```logql
{job="docker"} != "health"
```
Returned: `TODO`

**Query 5**
```logql
count_over_time({job="docker"}[5m])
```
Returned: `TODO: e.g. "A graph with one line per stream, rising after my curl loop"`

> **📸 Screenshot 7:** The `topk(5, sum by (container_name) (rate({job="docker"}[5m])))` graph.
>
> ![Top containers by log volume](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/51b078150c0ad97132ba67de178055ae46a33f9b/Day75/Screenshot/5.8%20top%20containers%20by%20volumn.png)

---

## Task 6: Correlate Metrics and Logs in Grafana

### 1. Logs panel on the Day 74 dashboard

Steps:
1. Opened the Day 74 dashboard > **Add > Visualization**.
2. Datasource: **Loki**.
3. Query: `{job="docker"}`
4. Visualization: **Logs**.
5. Title: **Container Logs**. Saved the dashboard.

> **📸 Screenshot 9:** Dashboard with the metric panels and the **Container Logs** panel.
>
> ![Dashboard with Container Logs panel](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7c30192350c2072d8d60d53c46434b6b4621de5e/Day75/Screenshot/Container%20logs%20grafana%20dashboard.png)

### 2. Explore split view

To create a visible spike I generated load:

```bash
for i in $(seq 1 500); do curl -s http://localhost:8000 > /dev/null; done
```

| Panel | Datasource | Query |
|---|---|---|
| Left | Prometheus | `rate(container_cpu_usage_seconds_total{name="notes-app"}[5m])` |
| Right | Loki | `{container_name="notes-app"}` |

> **Note:** `TODO: delete if not needed.` If cAdvisor did not attach the `name` label on Docker Desktop for Windows, I used the host-level query `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` instead.

### 3. Time sync

With **Sync time ranges** turned on, dragging across a spike in the metrics graph zooms the log panel to the same time window. This is how I debug in production: spot the metric anomaly, then read the exact log lines from that moment.

> **📸 Screenshot 10 (required):** Explore split view, CPU graph on the left and Loki logs on the right, same time range.
>
> ![Metrics and logs side by side](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7c30192350c2072d8d60d53c46434b6b4621de5e/Day75/Screenshot/6%20correlation%20.png)

### Document: How does having metrics and logs in the same tool help during incident response compared to separate systems?

With separate systems, an engineer finds the anomaly in one tool, switches to another, converts time zones, and manually matches timestamps. That wastes minutes during an outage. In Grafana, metrics and logs share one time range, so selecting a spike immediately shows the log lines from that exact moment.

- **Lower MTTR:** less hunting between tools.
- **Less context switching:** one UI and one workflow.
- **Easier root-cause analysis:** cause and effect appear together, such as a CPU spike next to a flood of error lines.
- **Shared view:** the whole team looks at the same dashboard during an incident.

**Example:** at 2:14 PM the checkout error rate jumps. Metrics say errors rose from 0.1% to 12%. The logs for the same minute say `connection refused: payments-db:5432` hundreds of times. Together they give the what and the why in seconds.

---

## Hints Applied

- Kept label cardinality low (`container_name`, `job`); no user or request IDs as labels.
- Used `|~ "(?i)error"` for case-insensitive matching.
- Debugged with `docker compose logs promtail` and the Promtail targets page at `http://localhost:9080/targets`.
- Promtail runs as a container, so it can read the Docker log path (important on Docker Desktop).
- `positions.yaml` tracks read progress; deleting it makes Promtail re-read all logs.
- Loki trades search power for simplicity and cost; it is not a replacement for Elasticsearch.

---

## Documentation Deliverables

### Updated `docker-compose.yml` with all services so far

> Replace the `notes-app`, Prometheus, Node Exporter, cAdvisor, and Grafana sections with your exact Day 74 versions if they differ. The new parts for today are `loki`, `promtail`, and `loki_data`.

```yaml
services:
  # ---------- Application ----------
  notes-app:
    # TODO: paste your notes-app service definition here
    container_name: notes-app
    ports:
      - "8000:8000"

  # ---------- Day 74: Metrics ----------
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    restart: unless-stopped

  # ---------- Day 75: Logs ----------
  loki:
    image: grafana/loki:latest
    container_name: loki
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yml:/etc/loki/loki-config.yml
      - loki_data:/loki
    command: -config.file=/etc/loki/loki-config.yml
    restart: unless-stopped

  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    ports:
      - "9080:9080"
    volumes:
      - ./promtail/promtail-config.yml:/etc/promtail/promtail-config.yml
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    command: -config.file=/etc/promtail/promtail-config.yml
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

### Comparison: Loki vs ELK stack

| Aspect | Loki (+ Promtail + Grafana) | ELK (Elasticsearch + Logstash + Kibana) |
|---|---|---|
| **Indexing** | Labels only; log text stored compressed | Full-text index of every field |
| **Storage cost** | Low (small index, cheap object storage) | High (index often as large as the data) |
| **Resource usage** | Light; can run as a single binary | Heavy; JVM memory and cluster tuning |
| **Operational complexity** | Simple | Complex (shards, replicas, mappings) |
| **Search speed** | Fast with good labels; slower for broad text scans | Very fast for arbitrary full-text search |
| **Query language** | LogQL (similar to PromQL) | KQL / Lucene / Elasticsearch DSL |
| **Analytics** | Basic log-derived metrics | Rich aggregations, relevance ranking, fuzzy search |
| **Grafana integration** | Native; metrics and logs side by side | Possible, but Kibana is the main UI |
| **Best fit** | Container/Kubernetes logs, teams on Prometheus + Grafana, cost-sensitive setups | Full-text search, security analytics (SIEM), compliance, complex investigations |

**When I would use Loki:** a Docker/Kubernetes environment where I already run Prometheus and Grafana, I mostly look up logs by service, pod, or environment, and I want low cost and low maintenance.

**When I would use ELK:** I need powerful full-text search over huge volumes, complex aggregations, or a SIEM/audit use case where every field must be searchable.

---

## Submission

1. Add `day-75-loki-promtail.md` (and the `screenshots/` folder) to `2026/day-75/`
2. Commit and push to my fork

```bash
mkdir -p 2026/day-75/screenshots
git add 2026/day-75
git commit -m "Add Day 75 - Loki and Promtail"
git push
```

---

## Learn in Public

> Added the second pillar of observability today -- logs. Set up Loki and Promtail to collect all Docker container logs, queried them with LogQL in Grafana, and correlated metrics with logs side by side. When a CPU spike happens, I can now instantly see the exact log lines from that moment.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
