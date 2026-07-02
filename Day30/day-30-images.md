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


