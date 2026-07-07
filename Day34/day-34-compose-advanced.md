# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Objective

Today's objective was to build a production-like Docker Compose setup using multiple services, health checks, restart policies, named networks, named volumes, and service dependencies.

---

# Task 1 – Build a Three-Service Stack

Created a Docker Compose project consisting of:

- Flask Web Application
- PostgreSQL Database
- Redis Cache

The Flask application connects to both PostgreSQL and Redis.

Project Structure

```
day-34/
│
├── docker-compose.yml
├── day-34-compose-advanced.md
│
└── app/
    ├── Dockerfile
    ├── requirements.txt
    └── app.py
```

---

# Task 2 – depends_on & Healthchecks

Added a healthcheck to PostgreSQL.

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
```

Configured the web service to wait until the database becomes healthy.

```yaml
depends_on:
  db:
    condition: service_healthy
```

Result:

- Database starts first.
- Docker waits until PostgreSQL is accepting connections.
- Flask starts only after the database is healthy.

This prevents startup errors caused by applications trying to connect too early.

---

# Task 3 – Restart Policies

Database service:

```yaml
restart: always
```

Testing:

Stopped the database container manually.

```bash
docker kill postgres-db
```

Docker automatically recreated the container.

Changed restart policy to:

```yaml
restart: on-failure
```

Result:

The container restarted only when it exited with a non-zero exit code.

### Notes

| Policy | Behavior |
|----------|----------|
| no | Never restart |
| always | Always restart even after manual stop or daemon restart |
| unless-stopped | Restart until manually stopped |
| on-failure | Restart only after failures |

---

# Task 4 – Custom Dockerfile

Instead of pulling an application image, Docker Compose built it locally.

```yaml
build: ./app
```

After changing the application code:

```bash
docker compose up --build
```

Docker rebuilt the image and recreated the container.

---

# Task 5 – Named Networks & Volumes

Created a custom network.

```yaml
networks:
  app-network:
```

Created a named volume.

```yaml
volumes:
  postgres-data:
```

Advantages:

- Persistent database storage
- Better isolation
- Easy service discovery

Added labels to each service.

```yaml
labels:
  app: flask
```

---

# Task 6 – Scaling

Scaled the web application.

```bash
docker compose up --scale web=3
```

Observation:

Docker successfully created three Flask containers.

However, only one container could use host port 5000.

Additional replicas failed to bind the same host port.

### Why?

Host ports must be unique.

All three containers cannot expose:

```
5000:5000
```

In production, scaling is typically handled behind a reverse proxy or load balancer such as:

- Nginx
- Traefik
- HAProxy
- Kubernetes Services

---

# Commands Used

Build and Start

```bash
docker compose up --build
```

View Running Containers

```bash
docker compose ps
```

View Logs

```bash
docker compose logs
```

Scale Web Application

```bash
docker compose up --scale web=3
```

Stop Services

```bash
docker compose down
```

Stop Services and Remove Volumes

```bash
docker compose down -v
```

---

# Key Concepts Learned

- Multi-container applications
- Docker Compose build
- Service dependencies
- Database healthchecks
- Restart policies
- Named networks
- Named volumes
- Labels
- Scaling containers
- Limitations of host port mapping

---

# Outcome

Successfully built a production-style Docker Compose application with:

- Flask Web App
- PostgreSQL Database
- Redis Cache
- Dockerfile build process
- Health checks
- Restart policies
- Persistent storage
- Custom networking
- Service scaling

This setup closely resembles real-world application deployments and provides a solid foundation for learning container orchestration.
