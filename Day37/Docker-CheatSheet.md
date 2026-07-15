# 🐳 Docker Cheat Sheet

> A quick reference for commonly used Docker commands during development and DevOps workflows.

---

# 📦 Container Commands

| Command | Description |
|---------|-------------|
| `docker run IMAGE` | Create and start a new container |
| `docker run -d IMAGE` | Run container in detached mode |
| `docker run -it IMAGE bash` | Run container interactively |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker stop CONTAINER` | Stop a running container |
| `docker start CONTAINER` | Start a stopped container |
| `docker restart CONTAINER` | Restart a container |
| `docker rm CONTAINER` | Remove a container |
| `docker exec -it CONTAINER bash` | Access a running container |
| `docker logs CONTAINER` | View container logs |
| `docker inspect CONTAINER` | Show detailed container information |

---

# 🖼️ Image Commands

| Command | Description |
|---------|-------------|
| `docker pull IMAGE` | Download an image |
| `docker build -t IMAGE_NAME .` | Build image from Dockerfile |
| `docker images` | List images |
| `docker rmi IMAGE` | Remove an image |
| `docker tag IMAGE NEW_TAG` | Create a new image tag |
| `docker push IMAGE` | Push image to Docker Hub |
| `docker history IMAGE` | Show image layer history |

---

# 💾 Volume Commands

| Command | Description |
|---------|-------------|
| `docker volume create NAME` | Create a volume |
| `docker volume ls` | List volumes |
| `docker volume inspect NAME` | View volume details |
| `docker volume rm NAME` | Remove a volume |

---

# 🌐 Network Commands

| Command | Description |
|---------|-------------|
| `docker network create NAME` | Create a network |
| `docker network ls` | List networks |
| `docker network inspect NAME` | Inspect a network |
| `docker network connect NETWORK CONTAINER` | Connect container to a network |
| `docker network rm NAME` | Remove a network |

---

# ⚙️ Docker Compose Commands

| Command | Description |
|---------|-------------|
| `docker compose up` | Start services |
| `docker compose up -d` | Start services in background |
| `docker compose down` | Stop and remove services |
| `docker compose down -v` | Remove services and volumes |
| `docker compose ps` | List running services |
| `docker compose logs` | Show logs |
| `docker compose build` | Build services |

---

# 🧹 Cleanup Commands

| Command | Description |
|---------|-------------|
| `docker system df` | Show Docker disk usage |
| `docker system prune` | Remove unused resources |
| `docker image prune` | Remove unused images |
| `docker container prune` | Remove stopped containers |
| `docker volume prune` | Remove unused volumes |
| `docker network prune` | Remove unused networks |

---

# 📝 Dockerfile Instructions

| Instruction | Purpose |
|-------------|---------|
| `FROM` | Base image |
| `RUN` | Execute commands during build |
| `COPY` | Copy files into image |
| `ADD` | Copy files or download URLs/extract archives |
| `WORKDIR` | Set working directory |
| `EXPOSE` | Document application port |
| `ENV` | Set environment variables |
| `CMD` | Default command when container starts |
| `ENTRYPOINT` | Main executable for the container |

---

# 🚀 Common Build Commands

```bash
docker build -t my-app:v1 .
docker run -d -p 8080:80 my-app:v1
docker push username/my-app:v1
docker compose up -d
docker compose down
```

---

# 💡 Quick Tips

- Images are templates; containers are running instances.
- Use named volumes for persistent data.
- Use bind mounts during development.
- Prefer multi-stage builds to reduce image size.
- Store secrets in `.env` files (never commit them).
- Use custom networks so containers can communicate by service name.

---

**Day 37 – Docker Revision & Cheat Sheet**

**#90DaysOfDevOps**
