# Day 29 – Introduction to Docker

## 📌 Objective

The goal of today is to understand Docker fundamentals, install Docker, and run the first containers.

---

# Task 1: What is Docker?

## What is Docker?

Docker is an open-source containerization platform that allows developers to package applications along with all their dependencies into lightweight, portable containers.

A Docker container runs the same way on every machine, eliminating the common problem of:

> "It works on my machine."

Docker ensures consistency across development, testing, and production environments.

---

## What is a Container?

A container is a lightweight, isolated environment that contains:

- Application code
- Runtime
- Libraries
- Dependencies
- Configuration files

Containers share the host operating system's kernel, making them much faster and smaller than virtual machines.

### Why do we need containers?

Without containers:

- Different machines have different environments.
- Dependency conflicts occur.
- Deployment becomes difficult.
- Applications behave differently on production servers.

Containers solve these problems by packaging everything the application needs into a single unit.

---

# Containers vs Virtual Machines

| Feature | Containers | Virtual Machines |
|----------|------------|------------------|
| Boot Time | Seconds | Minutes |
| Size | MBs | GBs |
| Performance | Near-native | Slower |
| OS | Share Host Kernel | Separate Guest OS |
| Resource Usage | Low | High |
| Isolation | Process-level | Hardware-level |

### Containers

- Lightweight
- Fast startup
- Share host OS
- Best for microservices and DevOps

### Virtual Machines

- Run full operating systems
- Better isolation
- Consume more RAM and storage
- Suitable for running different operating systems

---

# Docker Architecture

Docker follows a client-server architecture.

Main Components:

## 1. Docker Client

The Docker CLI (`docker`) is what users interact with.

Example:

```bash
docker run nginx
```

The client sends commands to the Docker Daemon.

---

## 2. Docker Daemon

The Docker Daemon (`dockerd`) is the background service responsible for:

- Building images
- Running containers
- Managing networks
- Managing volumes
- Pulling images

---

## 3. Docker Images

Images are read-only templates used to create containers.

Examples:

- nginx
- ubuntu
- mysql
- redis

---

## 4. Docker Containers

Containers are running instances of Docker images.

One image can create multiple containers.

---

## 5. Docker Registry

A registry stores Docker images.

Most popular:

Docker Hub

When Docker cannot find an image locally, it downloads it from Docker Hub.

---

# Docker Architecture Diagram

```

                Docker Hub
                      │
               Pull / Push Images
                      │
              +------------------+
              | Docker Daemon    |
              | (dockerd)        |
              +------------------+
                ▲            │
                │            │
      Docker CLI│            │Creates
     (docker)   │            ▼
          +-------------------------+
          |     Docker Containers   |
          +-------------------------+

```

---

# Task 2: Install Docker

## Install Docker Desktop

Downloaded Docker Desktop from:

https://www.docker.com/products/docker-desktop/

Installed successfully.

---

## Verify Installation

```bash
docker --version
```

Example Output

```bash
Docker version 28.x.x
```

Check Docker service

```bash
docker info
```

---

## Run Hello World

Command

```bash
docker run hello-world
```

Output

Docker:

- Pulled the image
- Created a container
- Executed it
- Displayed the success message
- Stopped the container

This confirms Docker is installed correctly.

---

# Task 3: Run Real Containers

## Run Nginx Container

```bash
docker run -d -p 8080:80 --name my-nginx nginx
```

Explanation:

- `-d` → Detached mode
- `-p` → Port mapping
- `--name` → Custom container name

Open Browser:

```
http://localhost:8080
```

The default Nginx welcome page should appear.

---

## Run Ubuntu Container

```bash
docker run -it ubuntu
```

Interactive shell opens.

Example commands:

```bash
pwd

ls

whoami

apt update

exit
```

---

## List Running Containers

```bash
docker ps
```

---

## List All Containers

```bash
docker ps -a
```

---

## Stop Container

```bash
docker stop my-nginx
```

---

## Remove Container

```bash
docker rm my-nginx
```

---

# Task 4: Explore Docker

## Run in Detached Mode

```bash
docker run -d nginx
```

Detached mode runs the container in the background.

Unlike interactive mode, it does not open a terminal.

---

## Give Container a Custom Name

```bash
docker run --name web-server nginx
```

---

## Port Mapping

```bash
docker run -d -p 8080:80 nginx
```

Host Port

```
8080
```

Container Port

```
80
```

Requests sent to:

```
localhost:8080
```

are forwarded to:

```
Container Port 80
```

---

## View Logs

```bash
docker logs my-nginx
```

Shows logs generated by the running container.

---

## Execute Command Inside Running Container

```bash
docker exec -it my-nginx bash
```

Example:

```bash
ls

pwd

whoami

exit
```

---

# Common Docker Commands Learned Today

| Command | Description |
|----------|-------------|
| `docker --version` | Check Docker version |
| `docker info` | Docker information |
| `docker images` | List images |
| `docker pull nginx` | Download image |
| `docker run nginx` | Run container |
| `docker run -d` | Detached mode |
| `docker run -it` | Interactive mode |
| `docker ps` | Running containers |
| `docker ps -a` | All containers |
| `docker stop` | Stop container |
| `docker rm` | Remove container |
| `docker logs` | View logs |
| `docker exec -it` | Enter running container |

---

# Key Takeaways

- Docker packages applications into portable containers.
- Containers are lightweight and share the host operating system kernel.
- Docker images are templates used to create containers.
- Docker Hub is the default registry for downloading images.
- Docker Daemon manages images and containers.
- Containers start much faster than virtual machines.
- Detached mode runs containers in the background.
- Port mapping allows access to containerized applications from the host machine.
- Docker simplifies application deployment and ensures consistency across environments.

---

