# Day 32 – Docker Volumes & Networking

## Objective

The goal of today's practice was to understand two important Docker concepts:

- Data Persistence using Docker Volumes
- Communication between containers using Docker Networks

---

# Task 1: The Problem – Data Loss Without Volumes

## Step 1: Pull PostgreSQL Image

```bash
docker pull postgres:17
```

## Step 2: Run PostgreSQL Container

```bash
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  postgres:17
```

## Step 3: Connect to PostgreSQL

```bash
docker exec -it postgres-db psql -U postgres
```

Create a table and insert data.

```sql
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO students(name)
VALUES ('Aditya');

SELECT * FROM students;
```

Exit PostgreSQL.

```sql
\q
```

## Step 4: Stop and Remove Container

```bash
docker stop postgres-db
docker rm postgres-db
[O```

## Step 5: Create a New Container

```bash
docker run -d \
  --name postgres-db-new \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  postgres:17
```

Connect again.

```bash
docker exec -it postgres-db-new psql -U postgres
```

Run

```sql
SELECT * FROM students;
```

Result:

```
ERROR: relation "students" does not exist
```

## Observation

The data was lost because it was stored inside the container filesystem. When the container was removed, all its data was deleted as well.

---

# Task 2: Docker Named Volumes

## Create a Volume

```bash
docker volume create postgres-data
```

Verify

```bash
docker volume ls
```

## Run PostgreSQL Using the Volume

```bash
docker run -d \
  --name postgres-volume \
  -e POSTGRES_PASSWORD=password \
  -v postgres-data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:17
```

## Create Data

```bash
docker exec -it postgres-volume psql -U postgres
```

```sql
CREATE TABLE employees(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO employees(name)
VALUES ('John');

SELECT * FROM employees;
```

Exit PostgreSQL.

```sql
\q
```

## Remove the Container

```bash
docker stop postgres-volume
docker rm postgres-volume
```

## Start a New Container with the Same Volume

```bash
docker run -d \
  --name postgres-volume-new \
  -e POSTGRES_PASSWORD=password \
  -v postgres-data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:17
```

Connect again.

```bash
docker exec -it postgres-volume-new psql -U postgres
```

Verify the data.

```sql
SELECT * FROM employees;
```

The data is still available.

## Inspect the Volume

```bash
docker volume ls
```

```bash
docker volume inspect postgres-data
```

## Observation

Named volumes store data outside the container, allowing it to persist even after the container is deleted.

---

# Task 3: Bind Mounts

## Create Project Folder

```
docker-demo/
└── index.html
```

Contents of **index.html**

```html
<h1>Hello from Docker Bind Mount!</h1>
```

## Run Nginx Container

### Git Bash

```bash
docker run -d \
  --name nginx-bind \
  -p 8080:80 \
  -v "/d/devops/docker-practice/docker-demo:/usr/share/nginx/html" \
  nginx
```

### PowerShell

```powershell
docker run -d `
  --name nginx-bind `
  -p 8080:80 `
  -v ${PWD}\docker-demo:/usr/share/nginx/html `
  nginx
```

Open the browser.

```
http://localhost:8080
```

Modify **index.html** and refresh the browser.

The changes appear instantly without rebuilding the container.

## Named Volume vs Bind Mount

| Named Volume | Bind Mount |
|--------------|------------|
| Managed by Docker | Managed by Host OS |
| Best for databases | Best for development |
| Docker decides storage location | Uses a specific host directory |
| Safer and portable | Easy live editing |

---

# Task 4: Docker Networking Basics

## List Networks

```bash
docker network ls
```

## Inspect Default Bridge Network

```bash
docker network inspect bridge
```

## Run Two Containers

```bash
docker run -dit --name alpine1 alpine sh
```

```bash
docker run -dit --name alpine2 alpine sh
```

Find alpine2 IP address.

```bash
docker inspect alpine2
```

Ping by IP.

```bash
docker exec alpine1 ping <IP_ADDRESS>
```

Result:

Successful.

Ping by container name.

```bash
docker exec alpine1 ping alpine2
```

Result:

Failed.

## Observation

The default bridge network does not provide automatic DNS-based name resolution between containers.

---

# Task 5: Custom Bridge Network

## Create Network

```bash
docker network create my-app-net
```

## Run Containers

```bash
docker run -dit --name app1 --network my-app-net alpine sh
```

```bash
docker run -dit --name app2 --network my-app-net alpine sh
```

Ping by container name.

```bash
docker exec app1 ping app2
```

Result:

Successful.

## Observation

Docker automatically provides DNS resolution for containers connected to the same user-defined bridge network.

---

# Task 6: Combine Everything

## Create Network

```bash
docker network create app-network
```

## Create Volume

```bash
docker volume create app-data
```

## Run PostgreSQL

```bash
docker run -d \
  --name postgres-app \
  -e POSTGRES_PASSWORD=password \
  -v app-data:/var/lib/postgresql/data \
  --network app-network \
  postgres:17
```

## Run Test Container

```bash
docker run -dit \
  --name test-client \
  --network app-network \
  alpine sh
```

Install ping utility.

```bash
docker exec test-client apk add iputils
```

Ping PostgreSQL container.

```bash
docker exec test-client ping postgres-app
```

Result:

Successful.

## Observation

Containers connected to the same custom network can communicate using container names, making service discovery simple and reliable.

---

# Key Learnings

## Container Storage vs Volumes

| Container Storage | Docker Volume |
|-------------------|---------------|
| Deleted with the container | Persists after container deletion |
| Temporary | Permanent |
| Not suitable for databases | Ideal for databases |

---

## Default Bridge vs Custom Bridge

| Default Bridge | Custom Bridge |
|----------------|---------------|
| No automatic DNS | Automatic DNS |
| Limited communication | Easy communication by container name |
| Manual IP lookup | Name-based communication |

---

# Commands Learned

```bash
docker volume create
docker volume ls
docker volume inspect

docker network ls
docker network inspect
docker network create

docker run -v
docker exec
docker stop
docker rm
docker ps
docker inspect
```

---

# Conclusion

Today I learned how Docker handles persistent storage using named volumes and how bind mounts enable real-time file synchronization between the host and containers. I also explored Docker networking, understanding the differences between the default bridge network and custom bridge networks. By combining volumes and custom networks, I successfully created a setup where containers could communicate using container names while ensuring database data remained persistent across container recreations.

---

# Screenshots

- PostgreSQL table before deleting the container
- Data loss after recreating the container without a volume
- `docker volume ls`
- `docker volume inspect postgres-data`
- Data persistence using a named volume
- Nginx page served through bind mount
- Live update after editing `index.html`
- `docker network ls`
- `docker network inspect bridge`
- Successful ping by IP on the default bridge
- Failed ping by container name on the default bridge
- Successful ping by container name on the custom network
- Successful communication between application and PostgreSQL container
