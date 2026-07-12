# Day 36 – Docker Project

## Objective

Dockerize a complete Node.js application with MongoDB.

---

## Technologies

- Docker
- Docker Compose
- Node.js
- Express.js
- MongoDB

---

## Dockerfile Explanation

### Stage 1

- Uses Node Alpine image.
- Installs dependencies.
- Copies project files.

### Stage 2

- Creates non-root user.
- Copies application from builder stage.
- Exposes port 3000.
- Starts application.

---

## Docker Compose

Includes:

- App service
- MongoDB service
- Named volume
- Custom bridge network
- Environment variables
- Healthcheck

---

## Challenges

- Fixed MongoDB connection using service name.
- Used Docker Compose healthcheck to ensure database starts before application.

---

## Final Result

Successfully Dockerized the application.

```
docker compose up --build
```

Application:

```
http://localhost:3000
```

Docker Hub:

```
https://hub.docker.com/r/<your-username>/day36-node-app
```
