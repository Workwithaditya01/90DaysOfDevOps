# Day 30 – Docker Images & Container Lifecycle

## Task 1: Docker images

### 1. Pull images from Docker Hub

```command
docker pull nginx
docker pull ubuntu
docker pull alpine
```

#### Screenshot
![Pull Images](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/d70e42d9fbfe63634f6d4d0a71ec42dc3ea4db61/images/Day%2030/Day%2030%201.png)

---

### 2.List All Images

```command
docker images
```

#### Screenshot
![All images](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/d70e42d9fbfe63634f6d4d0a71ec42dc3ea4db61/images/Day%2030/day%2030%202.png)

---

### 3.Ubuntu vs Alpine

#### Ubuntu
- General-purpose Linux Distribution
- Includes many packages and utilies
- Larger image size
- better For development environment

#### Alpine
- Minimal linux distribution
- very lightweight
- smaller attack surface
- faster downloads and deployment

---

### 4. Inspect an image

```command
docker image inspect nginx
```

#### Information Available
- Image ID
- Tags
- Creation date
- Operating System
- Architecture
- Environment variables
- Entrypoint
- Default command
- Layers
- Working directory

#### Screenshot
![inspect nginx](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/d70e42d9fbfe63634f6d4d0a71ec42dc3ea4db61/images/Day%2030/day%2030%202.png)

### 5. Remove an images

```command
docker rmi ubuntu
```

#### Screenshot
![Remove images](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/d70e42d9fbfe63634f6d4d0a71ec42dc3ea4db61/images/Day%2030/day%2030%204.png)

---

## Task 2: Image Layers

### view Image History

```command
docker image history nginx
```
#### Screenshot
![image history](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59eb4d0b88f4adee67d0070a2091b02ed32282ed/images/Day%2030/day%2050%205.png)

#### What are Docker Layers?

- Docker images are built using multiple read-only layers.

- Each instruction inside a Dockerfile creates a new layer.

- Examples:
```command
FROM
RUN
COPY
ADD
ENV
```
- When a container starts, Docker adds one writable layer on top of these read-only layers.

#### Why Docker Uses Layers
- Faster image downloads
- Layer caching speeds up builds
- Shared layers reduce disk usage
- Easy image versioning
- Efficient image distribution
 
#### Why do some layers show 0B?

- Layers showing 0B usually represent metadata changes such as:
```command
ENV
CMD
EXPOSE
LABEL
WORKDIR
```
- These instructions modify image metadata without adding filesystem data.

---

## Task 3: Container lifecycle

### 1.Create Container

```command
docker create --name lifecycle-demo nginx
```
```command
docker ps -a
```

#### Screenshot:
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/day%2030-6.png)

### 2.Start Container

```command
docker start lifecycle-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/day%2030-7.png)

### 3. Pause Container

```command
docker pause lifecycle-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/docker%2030-8.png)

### 4. unpause container

```command
docker unpause lifecycle-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/day%2030-9.png)

### 5. Stop Container

```command
docker stop lifecycle-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/day%2030-10.png)

### 6. Restart container

```command
docker restart lifecycle-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/day%2030-11.png)


### 7. Kill Container

```command
docker kill lifecycle-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/day%2030-12.png)

### 8. Remove Container

```command
docker rm lifecycle-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/59d006a2fb2cd8b48211e1b202460f31ecc819cc/images/Day%2030/day%2030-13.png)

---

## Task 4: Working with Running Containers

### Run nginx in Detached mode

```command
docker run -d --name -p 8080:80 nginx-demo nginx
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a27a28c34f43b3187b73ff190e4beb5e5128b3ca/images/Day%2030/day%2013-13%202.png)

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a27a28c34f43b3187b73ff190e4beb5e5128b3ca/images/Day%2030/day%2013-14.png)


### View logs

```command
docker logs nginx-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a27a28c34f43b3187b73ff190e4beb5e5128b3ca/images/Day%2030/day%2013-15.png)

### Follow Logs

```command
docker logs -f nginx-demo
```

#### Screenshot
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a27a28c34f43b3187b73ff190e4beb5e5128b3ca/images/Day%2030/day%2013-16.png)


### Exectue in Container

```command
docker exec -it nginx-demo nginx
```

#### Command
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a27a28c34f43b3187b73ff190e4beb5e5128b3ca/images/Day%2030/day%2013-17.png)


### Run a Single command

```command
docker exec nginx-demo ls
```

#### Screenshot:
![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a27a28c34f43b3187b73ff190e4beb5e5128b3ca/images/Day%2030/day%2013-18.png)

### Inspect Container

```command
docker inspect nginx-demo
```

#### Find:

- Container ID
- IP Address
- Port Bindings
- Mounts
- Network Settings
- Restart Policy
- Image Used

---

## Task 5: Cleanup

### Stop all running containers

```command
docker stop $(docker ps -q)
```

### Remove all Stopped containers

```command
docker container prune
```

#### Or

```command
docker container prune -a
```

### Remove Unused Images

```command
docker image prune
```

### Check docker Disk Usage

```command
docker system df
```

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/d1386ac949205d72860aa2e63587b24a60130753/images/Day%2030/30%20last.png)

---

## Key Learnings
- Docker images are templates used to create containers.
- Containers are running instances of images.
- Docker images are built from multiple reusable layers.
- Layer caching makes image builds faster and more storage-efficient.
- Containers move through different lifecycle states such as Created, Running, Paused, Exited, and Removed.
- Docker provides powerful tools like inspect, logs, exec, and history for debugging and management.
- Regular cleanup helps reclaim disk space and keeps the Docker environment organized.

---

## Commands Practiced:
docker pull
docker images
docker image inspect
docker image history 
docker rmi

docker create
docker start
docker pause
docker unpause
docker stop
docker restart
docker kill 
docker rm

docker ps
docker ps -a
docker logs
docker logs -f
docker exec
docker inspect
docker container prune
docker image prune
docker system prune 
docker system df

---


