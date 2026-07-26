# Day 45 – Docker Build & Push in GitHub Actions

## Objective

Build a complete CI/CD pipeline using GitHub Actions that automatically builds a Docker image and pushes it to Docker Hub.

---

# Prerequisites

Before starting, make sure you have:

- A GitHub repository
- A valid Dockerfile
- A Docker Hub account
- GitHub Secrets configured:
  - `DOCKER_USERNAME`
  - `DOCKER_TOKEN`

---

# Task 1 – Prepare

## Goal

Prepare the repository for Docker CI/CD.

### Steps Performed

- Added a Dockerfile to the repository.
- Verified the Dockerfile builds successfully.
- Configured the following GitHub Secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_TOKEN`

---

# Task 2 – Build the Docker Image

## Goal

Build the Docker image automatically whenever code is pushed to the `main` branch.

## Workflow

```yaml
name: Docker Build

on:
  push:
    branches:
      - main

jobs:
  Build-Tag:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Build Docker Image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          tags: my-app:latest
```

## What this workflow does

- Triggers when code is pushed to the `main` branch.
- Checks out the repository.
- Builds the Docker image.
- Does **not** push the image to Docker Hub.

---

# Task 3 – Build and Push the Docker Image

## Goal

Authenticate with Docker Hub and push the Docker image after building it.

## Workflow

```yaml
name: Docker Build & Push

on:
  push:
    branches:
      - main

jobs:
  docker:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and Push Image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            adityasondekar/my-app:latest
```

## What this workflow does

- Builds the Docker image.
- Logs in to Docker Hub securely using GitHub Secrets.
- Pushes the Docker image to Docker Hub with the `latest` tag.

---

# Task 4 – Push Only on the Main Branch

## Goal

Build the Docker image on every branch, but only push it to Docker Hub when changes are merged into the `main` branch.

## Workflow

```yaml
name: Docker Build & Push

on:
  push:
    branches:
      - main
      - feature/**
  pull_request:

jobs:
  docker:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Login to Docker Hub
        if: github.ref == 'refs/heads/main'
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build Docker Image
        if: github.ref != 'refs/heads/main'
        uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          tags: my-app:test

      - name: Build and Push Docker Image
        if: github.ref == 'refs/heads/main'
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/my-app:latest
            ${{ secrets.DOCKER_USERNAME }}/my-app:sha-${{ env.SHORT_SHA }}
```

## Workflow Behavior

### Push to a Feature Branch

```
Push Code
      ↓
GitHub Actions Starts
      ↓
Checkout Repository
      ↓
Build Docker Image
      ↓
Workflow Finished
```

- Docker image is built successfully.
- Image is **not** pushed to Docker Hub.

### Push to the Main Branch

```
Push Code
      ↓
GitHub Actions Starts
      ↓
Checkout Repository
      ↓
Login to Docker Hub
      ↓
Build Docker Image
      ↓
Push latest Image
      ↓
Push SHA Tagged Image
```

- Docker image is built.
- Docker Hub authentication succeeds.
- Images are pushed to Docker Hub.

---

# Task 5 – Add a Workflow Status Badge

## Goal

Display the workflow status directly in the repository's `README.md`.

### Steps

1. Open your GitHub repository.
2. Click the **Actions** tab.
3. Select the **Docker Build & Push** workflow.
4. Click **Create status badge**.
5. Copy the generated Markdown.
6. Paste it into your `README.md`.

### Example

```markdown
# GitHub Actions Practice

[![Docker-Build-Tag](https://github.com/Workwithaditya01/Actions-practice/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Workwithaditya01/Actions-practice/actions/workflows/docker-publish.yml)

Learning GitHub Actions and Docker CI/CD.
```

The badge automatically updates after every workflow execution.

---

# Task 6 – Pull and Run the Image

## Pull the Image

```bash
docker pull adityasondekar/my-app:latest
```

## Run the Container

```bash
docker run -d -p 8080:80 adityasondekar/my-app:latest
```

## Verify

Open your browser and visit:

```
http://localhost:8080
```

If everything is configured correctly, your application should be running successfully.

---

# Complete CI/CD Journey

```
Developer Writes Code
        │
        ▼
git add .
        │
git commit
        │
git push
        │
        ▼
GitHub Repository
        │
        ▼
GitHub Actions Workflow
        │
        ▼
Checkout Repository
        │
        ▼
Build Docker Image
        │
        ▼
Login to Docker Hub
        │
        ▼
Push Docker Image
        │
        ▼
Docker Hub Registry
        │
        ▼
docker pull
        │
        ▼
docker run
        │
        ▼
Running Container
```

---

# Learning Outcomes

After completing Day 45, I learned:

- How GitHub Actions automates Docker image builds.
- How to authenticate with Docker Hub using GitHub Secrets.
- How to push Docker images automatically from a workflow.
- How to use conditional execution to publish images only from the `main` branch.
- How to display workflow status using a GitHub Actions badge.
- How a complete CI/CD pipeline works from code commit to a running Docker container.

---

# Repository Structure

```
github-actions-practice/
│
├── Dockerfile
├── README.md
│
├── .github/
│   └── workflows/
│       └── docker-publish.yml
│
└── 2026/
    └── day-45/
        └── day-45-docker-cicd.md
```

---

# Conclusion

Day 45 focused on building a production-style Docker CI/CD pipeline using GitHub Actions. The workflow automatically builds Docker images, authenticates with Docker Hub using GitHub Secrets, and publishes images only from the `main` branch. This exercise provided practical experience with Continuous Integration, Continuous Deployment, Docker image management, and workflow automation.
