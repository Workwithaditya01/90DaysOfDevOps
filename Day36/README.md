# Dockerized Node.js + MongoDB Project

## Overview

This project demonstrates Dockerizing a Node.js Express application with MongoDB using Docker Compose.

## Technologies

- Node.js
- Express.js
- MongoDB
- Docker
- Docker Compose

## Features

- Multi-stage Docker build
- Non-root user
- Docker Compose
- MongoDB healthcheck
- Persistent volume
- Custom Docker network

## Run

```bash
docker compose up --build
```

Visit:

```
http://localhost:3000
```

Stop:

```bash
docker compose down
```

## Environment Variable

```
PORT
MONGO_URI
```
