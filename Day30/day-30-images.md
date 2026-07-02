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


