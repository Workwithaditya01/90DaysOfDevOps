# Day 31 – Dockerfile: Build Your Own Images

## Objective

Today's goal was to learn how to create custom Docker images using Dockerfiles.

Topics covered:

- Writing Dockerfiles
- Building Docker images
- Understanding common Dockerfile instructions
- Difference between CMD and ENTRYPOINT
- Building a static website image using Nginx
- Using .dockerignore
- Docker build cache optimization

---

# Task 1 – My First Dockerfile

## Project Structure

```
my-first-image/
│── Dockerfile
```

## Dockerfile

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl

CMD ["echo", "Hello from my custom image!"]
```

## Build Image

```bash
docker build -t my-ubuntu:v1 .
```

## Run Container

```bash
docker run --rm my-ubuntu:v1
```

## Output

```
Hello from my custom image!
```

### What I Learned

- `FROM` selects the base image.
- `RUN` executes commands during image build.
- `CMD` defines the default command when the container starts.

---

# Task 2 – Dockerfile Instructions

## Project Structure

```
dockerfile-demo/
│── Dockerfile
│── message.txt
```

## message.txt

```
Dockerfile Instructions Demo
```

## Dockerfile

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl

WORKDIR /app

COPY message.txt .

EXPOSE 8080

CMD ["cat", "message.txt"]
```

## Build

```bash
docker build -t docker-demo:v1 .
```

## Run

```bash
docker run --rm docker-demo:v1
```

## Dockerfile Instructions Explained

| Instruction | Purpose |
|------------|---------|
| FROM | Specifies the base image |
| RUN | Executes commands while building the image |
| WORKDIR | Sets the working directory |
| COPY | Copies files from host to image |
| EXPOSE | Documents the application's port |
| CMD | Default command executed when container starts |

---

# Task 3 – CMD vs ENTRYPOINT

## Dockerfile using CMD

```dockerfile
FROM ubuntu:latest

CMD ["echo", "hello"]
```

### Build

```bash
docker build -t cmd-demo .
```

### Run

```bash
docker run cmd-demo
```

Output

```
hello
```

### Override CMD

```bash
docker run cmd-demo ls
```

Output

```
Lists directory contents instead of printing hello
```

---

## Dockerfile using ENTRYPOINT

```dockerfile
FROM ubuntu:latest

ENTRYPOINT ["echo"]
```

### Build

```bash
docker build -t entrypoint-demo .
```

### Run

```bash
docker run entrypoint-demo hello
```

Output

```
hello
```

### Run

```bash
docker run entrypoint-demo Docker is awesome
```

Output

```
Docker is awesome
```

## CMD vs ENTRYPOINT

### CMD

- Provides a default command.
- Can be completely overridden at runtime.
- Best when users may want different commands.

### ENTRYPOINT

- Defines the main executable.
- Additional arguments are appended.
- Best for creating dedicated executables or CLI tools.

---

# Task 4 – Build a Simple Website

## Project Structure

```
my-website/
│── Dockerfile
│── index.html
```

## index.html

```html
<!DOCTYPE html>
<html>
<head>
    <title>My Docker Website</title>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This website is running inside an Nginx container.</p>
</body>
</html>
```

## Dockerfile

```dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/

EXPOSE 80
```

## Build

```bash
docker build -t my-website:v1 .
```

## Run

```bash
docker run -d -p 8080:80 my-website:v1
```

Visit:

```
http://localhost:8080
```

Expected Result:

The custom HTML page loads successfully.

---

# Task 5 – Using .dockerignore

## .dockerignore

```
node_modules
.git
*.md
.env
```

## Why use .dockerignore?

- Reduces build context size.
- Speeds up image builds.
- Prevents sensitive files from being copied.
- Produces smaller images.

---

# Task 6 – Docker Build Optimization

## First Build

```bash
docker build -t cache-demo:v1 .
```

Docker builds every layer.

---

## Modify One Line

For example, change:

```dockerfile
CMD ["echo", "Version 1"]
```

to

```dockerfile
CMD ["echo", "Version 2"]
```

Rebuild:

```bash
docker build -t cache-demo:v2 .
```

Docker reuses cached layers except the changed layer and those after it.

---

## Optimized Dockerfile Layout

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

### Why This Is Better

Dependencies change less frequently than application code.

Docker caches dependency installation, making future builds much faster.

---

# Key Takeaways

- Dockerfiles define how images are built.
- Every instruction creates a new image layer.
- CMD provides default commands that users can override.
- ENTRYPOINT creates executable-style containers.
- .dockerignore improves build performance and security.
- Layer caching significantly speeds up rebuilds.
- Ordering Dockerfile instructions correctly results in faster builds.

---

# Files Created

```
2026/
└── day-31/
    ├── day-31-dockerfile.md
    ├── my-first-image/
    │   └── Dockerfile
    ├── dockerfile-demo/
    │   ├── Dockerfile
    │   └── message.txt
    ├── cmd-demo/
    │   └── Dockerfile
    ├── entrypoint-demo/
    │   └── Dockerfile
    ├── my-website/
    │   ├── Dockerfile
    │   ├── index.html
    │   └── .dockerignore
```

---

# Conclusion

Today I learned how Dockerfiles are used to create reusable and portable container images. I explored essential Dockerfile instructions, understood the difference between CMD and ENTRYPOINT, built a custom Nginx-based web image, optimized builds using layer caching, and improved build efficiency with `.dockerignore`.
