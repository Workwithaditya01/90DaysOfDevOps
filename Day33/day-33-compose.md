# Day 33 – Docker Compose: Multi-Container Basics

## Objective

The goal of today's task is to learn how to use **Docker Compose** to manage one or more containers using a single YAML configuration file.

Instead of running multiple `docker run` commands manually, Docker Compose allows us to define our entire application stack in a `docker-compose.yml` file and start everything with a single command.

---

# What is Docker Compose?

Docker Compose is a tool that helps define and manage multi-container Docker applications.

With Docker Compose, you can:

- Run multiple containers with a single command.
- Automatically create networks.
- Create and manage named volumes.
- Configure environment variables.
- Easily start, stop, rebuild, and remove an application stack.

---

# Prerequisites

- Docker Desktop installed
- Docker Engine running
- Docker Compose installed (comes with Docker Desktop)

---

# Folder Structure

```text
day-33/
│
├── day-33-compose.md
│
├── compose-basics/
│   └── docker-compose.yml
│
└── wordpress-mysql/
    ├── docker-compose.yml
    └── .env
```

---

# Task 1 – Install & Verify Docker Compose

## Check Docker Compose Version

```bash
docker compose version
```

### Output

```text
Docker Compose version v2.x.x
```

---

## Verify Docker Installation

```bash
docker version
```

### Screenshot

> Insert screenshot of Docker Compose version here.

---

# Task 2 – Your First Compose File

## Step 1 – Create Project Folder

```bash
mkdir compose-basics
cd compose-basics
```

---

## Step 2 – Create docker-compose.yml

```yaml
services:
  nginx:
    image: nginx
    container_name: compose-nginx
    ports:
      - "8080:80"
```

---

## Step 3 – Start the Container

```bash
docker compose up
```

Run in detached mode:

```bash
docker compose up -d
```

---

## Step 4 – Verify

```bash
docker compose ps
```

---

## Step 5 – Open in Browser

```
http://localhost:8080
```

The Nginx Welcome Page should appear.

---

## Step 6 – Stop the Service

```bash
docker compose down
```

---

### Screenshot

- Nginx Welcome Page
- docker compose ps

---

# Task 3 – WordPress + MySQL Multi-Container Setup

## Step 1 – Create Project Folder

```bash
mkdir wordpress-mysql
cd wordpress-mysql
```

---

## Step 2 – Create .env File

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=password123
MYSQL_ROOT_PASSWORD=root123
```

---

## Step 3 – Create docker-compose.yml

```yaml
services:

  db:
    image: mysql:8.0
    container_name: mysql-db

    restart: always

    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}

    volumes:
      - mysql_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: wordpress-app

    restart: always

    depends_on:
      - db

    ports:
      - "8081:80"

    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}

volumes:
  mysql_data:
```

---

## Step 4 – Start the Stack

```bash
docker compose up -d
```

---

## Step 5 – Verify Running Containers

```bash
docker compose ps
```

or

```bash
docker ps
```

---

## Step 6 – Open WordPress

```
http://localhost:8081
```

Complete the WordPress installation.

---

## Step 7 – Verify Persistent Storage

Stop the application:

```bash
docker compose down
```

Start again:

```bash
docker compose up -d
```

Open WordPress again.

If your website and setup are still present, the named volume has successfully persisted the database.

---

### Screenshot

- WordPress installation page
- WordPress dashboard
- docker compose ps

---

# Task 4 – Docker Compose Commands

## Start Services

```bash
docker compose up
```

Detached mode:

```bash
docker compose up -d
```

---

## View Running Services

```bash
docker compose ps
```

---

## View Logs

All services:

```bash
docker compose logs
```

Live logs:

```bash
docker compose logs -f
```

Specific service:

```bash
docker compose logs wordpress
```

or

```bash
docker compose logs db
```

---

## Stop Services

```bash
docker compose stop
```

Restart them:

```bash
docker compose start
```

---

## Remove Containers and Network

```bash
docker compose down
```

Remove containers, network, and volumes:

```bash
docker compose down -v
```

---

## Rebuild Images

```bash
docker compose up --build
```

---

### Screenshot

Insert screenshots of:

- docker compose logs
- docker compose stop
- docker compose down

---

# Task 5 – Environment Variables

Docker Compose automatically loads variables from a `.env` file.

Current `.env`:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=password123
MYSQL_ROOT_PASSWORD=root123
```

These variables are referenced inside the compose file using:

```yaml
${MYSQL_DATABASE}
${MYSQL_USER}
${MYSQL_PASSWORD}
${MYSQL_ROOT_PASSWORD}
```

---

## Verify Environment Variables

```bash
docker compose config
```

Docker Compose will display the fully resolved configuration with all environment variables substituted.

---

### Screenshot

Insert screenshot of:

```bash
docker compose config
```

---

# Docker Compose Commands Cheat Sheet

| Command | Description |
|----------|-------------|
| `docker compose up` | Start services |
| `docker compose up -d` | Start services in detached mode |
| `docker compose ps` | Show running services |
| `docker compose logs` | Display logs of all services |
| `docker compose logs -f` | Follow logs in real time |
| `docker compose logs <service>` | Show logs for a specific service |
| `docker compose stop` | Stop running services |
| `docker compose start` | Restart stopped services |
| `docker compose down` | Remove containers and networks |
| `docker compose down -v` | Remove containers, networks, and volumes |
| `docker compose config` | Display the resolved Compose configuration |
| `docker compose up --build` | Rebuild images and start services |

---

# Key Concepts Learned

- Introduction to Docker Compose
- YAML syntax
- Running containers using Docker Compose
- Multi-container applications
- Automatic Docker networking
- Named volumes for persistent storage
- Service-to-service communication using service names
- Environment variables using `.env`
- Docker Compose lifecycle commands
- Viewing logs and managing services
- Rebuilding and removing application stacks

---

# Challenges Completed

- [x] Verified Docker Compose installation
- [x] Created first Docker Compose project
- [x] Deployed an Nginx container
- [x] Created a WordPress + MySQL multi-container application
- [x] Configured persistent storage using named volumes
- [x] Used environment variables through a `.env` file
- [x] Practiced common Docker Compose commands
- [x] Verified data persistence after restarting containers

---

# Conclusion

Today I learned how Docker Compose simplifies container orchestration by allowing an entire application stack to be defined in a single `docker-compose.yml` file. Instead of manually creating networks, volumes, and containers, Docker Compose automates these tasks and makes multi-container applications easy to deploy and manage. I also learned how services communicate using built-in networking, how named volumes preserve data across container restarts, and how environment variables can be managed efficiently using a `.env` file.
