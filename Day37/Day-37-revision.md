# 📘 Day 37 – Docker Revision

## 🎯 Goal

Revise everything learned from Docker Days 29–36 and verify understanding through self-assessment and quick revision questions.

---

# ✅ Self-Assessment Checklist

| Topic | Status |
|--------|--------|
| Run containers (interactive & detached) | ✅ Can Do |
| List, stop and remove containers/images | ✅ Can Do |
| Explain image layers and caching | ✅ Can Do |
| Write a Dockerfile from scratch | ✅ Can Do |
| Explain CMD vs ENTRYPOINT | ✅ Can Do |
| Build and tag custom images | ✅ Can Do |
| Create and use named volumes | ✅ Can Do |
| Use bind mounts | ✅ Can Do |
| Create custom Docker networks | ✅ Can Do |
| Write docker-compose.yml | ✅ Can Do |
| Use environment variables with Compose | ✅ Can Do |
| Write multi-stage Dockerfiles | ✅ Can Do |
| Push images to Docker Hub | ✅ Can Do |
| Use healthchecks and depends_on | 🟡 Shaky |

---

# ⚡ Quick-Fire Questions

## 1. What is the difference between an image and a container?

An image is a read-only blueprint used to create containers. A container is a running instance of an image.

---

## 2. What happens to data inside a container when you remove it?

Container data is deleted unless it is stored in a named volume or bind mount.

---

## 3. How do two containers on the same custom network communicate?

They communicate using each other's container or service names through Docker's internal DNS.

---

## 4. What does `docker compose down -v` do differently from `docker compose down`?

- `docker compose down` removes containers and networks.
- `docker compose down -v` also removes associated named volumes.

---

## 5. Why are multi-stage builds useful?

They reduce image size by keeping only the files required for the final application.

---

## 6. What is the difference between COPY and ADD?

- `COPY` copies local files.
- `ADD` can also download remote files and automatically extract compressed archives.

---

## 7. What does `-p 8080:80` mean?

Maps host port **8080** to container port **80**.

---

## 8. How do you check Docker disk usage?

```bash
docker system df
```

---

# 📚 Revision Summary

During this revision, I reviewed:

- Docker Images
- Containers
- Dockerfile Instructions
- Image Layers
- Docker Build Cache
- Named Volumes
- Bind Mounts
- Docker Networks
- Docker Compose
- Environment Variables
- Multi-stage Docker Builds
- Docker Hub
- Health Checks
- Docker Cleanup Commands

---

# 🔄 Weak Spot Revisited

## Topic

Healthchecks and `depends_on`

### What I revised

- Added health checks to Docker Compose services.
- Understood how `depends_on` controls startup order.
- Learned that `depends_on` does not guarantee application readiness unless combined with health checks.

---

# 🎯 Key Takeaways

- Docker images are immutable templates.
- Containers are isolated running environments.
- Named volumes preserve data beyond container lifecycle.
- Bind mounts are ideal for development.
- Docker Compose simplifies multi-container applications.
- Multi-stage builds create smaller and more secure images.
- Docker networking enables seamless container communication.
- Regular cleanup helps save disk space.

---

## ✅ Day 37 Completed

Docker revision completed successfully.

Ready to continue with the next phase of the **#90DaysOfDevOps** challenge.

**#TrainWithShubham**
