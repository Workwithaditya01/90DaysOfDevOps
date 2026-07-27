# 🚀 Day 45 – Docker Build & Push with GitHub Actions

## 📖 Overview

This project demonstrates how to automate Docker image building and publishing using **GitHub Actions**. A complete CI/CD pipeline is created that builds a Docker image whenever code is pushed to the repository and publishes it to Docker Hub only when the changes are made to the `main` branch.

This exercise provides hands-on experience with GitHub Actions, Docker, Docker Hub, GitHub Secrets, and conditional workflow execution.

---

## 🎯 Objectives

- Build Docker images automatically using GitHub Actions.
- Authenticate securely with Docker Hub using GitHub Secrets.
- Push Docker images to Docker Hub.
- Publish images only from the `main` branch.
- Add a workflow status badge to the project.
- Understand the complete Docker CI/CD workflow.

---

## 🛠️ Technologies Used

- GitHub Actions
- Docker
- Docker Hub
- GitHub Secrets
- YAML

---

## 📚 Tasks Completed

### ✅ Task 1 – Repository Preparation

- Added a Dockerfile to the repository.
- Configured GitHub Secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_TOKEN`

---

### ✅ Task 2 – Build Docker Image

Created a GitHub Actions workflow that:

- Runs on every push to the `main` branch.
- Checks out the repository.
- Builds the Docker image successfully.
- Does not push the image to Docker Hub.

---

### ✅ Task 3 – Push Image to Docker Hub

Enhanced the workflow by:

- Logging in to Docker Hub securely.
- Building the Docker image.
- Publishing the Docker image with the `latest` tag.

---

### ✅ Task 4 – Push Only on Main Branch

Implemented conditional execution so that:

- Feature branches build the Docker image only.
- Images are pushed to Docker Hub only from the `main` branch.

This prevents unnecessary image uploads during development.

---

### ✅ Task 5 – Workflow Status Badge

Added a GitHub Actions workflow badge to the project README to display the current workflow status automatically.

---

### ✅ Task 6 – Pull and Run the Image

Verified the published image by:

- Pulling it from Docker Hub.
- Running it locally using Docker.
- Confirming that the container starts successfully.

---

## 🔄 CI/CD Workflow

```text
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
Authenticate with Docker Hub
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

## 📖 Key Learnings

- Automating Docker builds using GitHub Actions.
- Using GitHub Secrets to securely store credentials.
- Publishing Docker images to Docker Hub.
- Applying conditional execution in GitHub Actions workflows.
- Understanding the difference between building and pushing Docker images.
- Implementing a simple production-style CI/CD pipeline.

---

## 🎓 Conclusion

This project demonstrates how Continuous Integration and Continuous Deployment can automate Docker image creation and publishing. By integrating GitHub Actions with Docker Hub, the entire workflow becomes automated, reducing manual effort and ensuring consistent deployments. This exercise provides practical experience with modern DevOps practices used in real-world software development.

---

## 👨‍💻 Author

**Aditya Sondekar**

Learning DevOps through the **#90DaysOfDevOps** challenge.
