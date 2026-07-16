# Day 39 – CI/CD Concepts

## 📌 Objective

Before building CI/CD pipelines, it is important to understand **why CI/CD exists**, how it improves software delivery, and the key components of a pipeline.

---

# Task 1 – The Problem

## Imagine a Team of 5 Developers

Five developers are working on the same project and manually deploying changes to production.

### What can go wrong?

- Merge conflicts between developers
- Bugs reaching production
- Human deployment mistakes
- Different development environments causing inconsistent behavior
- Missing dependencies
- Difficult rollbacks
- Slow release process
- Increased downtime during deployments

---

## What does "It Works on My Machine" mean?

"It works on my machine" means the application runs correctly on the developer's computer but fails on another developer's machine, testing environment, or production server.

### Why does this happen?

- Different operating systems
- Different software versions
- Missing libraries or dependencies
- Environment variable differences
- Configuration mismatches

CI helps eliminate these issues by testing code in a clean, standardized environment.

---

## How many times can a team safely deploy manually?

Usually only **1–3 deployments per day** depending on project complexity.

Manual deployments become risky as deployment frequency increases because they rely on human intervention.

---

# Task 2 – CI vs CD

## Continuous Integration (CI)

Continuous Integration is the practice of automatically building and testing code whenever developers push changes to the repository.

It helps detect bugs, build failures, and integration issues early.

### Real-world Example

A developer pushes code to GitHub.

GitHub Actions automatically:

- Installs dependencies
- Builds the application
- Runs unit tests
- Runs lint checks

If any test fails, the merge request is blocked.

---

## Continuous Delivery (CD)

Continuous Delivery automatically prepares software for release after successful CI.

The application is deployment-ready, but a human decides when to deploy.

### Real-world Example

After tests pass, a Docker image is built and uploaded to Docker Hub.

The Production deployment waits for a manual approval.

---

## Continuous Deployment (CD)

Continuous Deployment automatically deploys every successful change to production without manual approval.

Every successful pipeline becomes a production release.

### Real-world Example

A website automatically updates immediately after all tests pass.

No human approval is required.

---

# CI vs Delivery vs Deployment

| Feature | Continuous Integration | Continuous Delivery | Continuous Deployment |
|----------|-----------------------|---------------------|-----------------------|
| Build Code | ✅ | ✅ | ✅ |
| Run Tests | ✅ | ✅ | ✅ |
| Deploy Automatically | ❌ | ❌ (Manual Approval) | ✅ |
| Human Approval Needed | No | Yes | No |

---

# Task 3 – Pipeline Anatomy

## Trigger

The event that starts the pipeline.

Examples:

- Git Push
- Pull Request
- Scheduled Cron Job
- Manual Trigger

---

## Stage

A major phase of the pipeline.

Common stages:

- Build
- Test
- Security Scan
- Package
- Deploy

---

## Job

A group of related tasks executed inside a stage.

Example:

Build Stage

Job:
- Build Docker Image

---

## Step

A single command or action inside a job.

Example:

```bash
npm install
```

```bash
npm test
```

```bash
docker build .
```

---

## Runner

A machine that executes pipeline jobs.

Examples:

- GitHub Hosted Runner
- Self-hosted Runner
- Jenkins Agent

---

## Artifact

Files produced during the pipeline.

Examples:

- Docker Image
- JAR File
- ZIP Package
- Build Reports
- Test Reports

---

# Task 4 – CI/CD Pipeline Diagram

```
                 Developer
                     │
                     │
              Push Code to GitHub
                     │
                     ▼
      ┌──────────────────────────┐
      │     Trigger Pipeline      │
      └──────────────────────────┘
                     │
                     ▼
      ┌──────────────────────────┐
      │      Build Stage          │
      │ - Install Dependencies    │
      │ - Build Application       │
      └──────────────────────────┘
                     │
                     ▼
      ┌──────────────────────────┐
      │       Test Stage          │
      │ - Unit Tests              │
      │ - Lint Checks             │
      └──────────────────────────┘
                     │
                     ▼
      ┌──────────────────────────┐
      │   Docker Build Stage      │
      │ - Build Docker Image      │
      │ - Push Image              │
      └──────────────────────────┘
                     │
                     ▼
      ┌──────────────────────────┐
      │     Deploy Stage          │
      │ Deploy to Staging Server  │
      └──────────────────────────┘
                     │
                     ▼
               Application Ready
```

---

# Task 5 – Explore in the Wild

## Repository Chosen

**React**

Repository:
https://github.com/facebook/react

Workflow Folder:

```
.github/workflows/
```

Workflow Examined:

```
runtime_build_and_test.yml
```

---

## What triggers it?

- Push
- Pull Request

---

## How many jobs does it have?

Approximately **5+ jobs**, including:

- Build
- Test
- Lint
- Compiler checks
- Various validation tasks

---

## What does it do?

The workflow automatically:

- Installs dependencies
- Builds React
- Runs tests
- Checks formatting
- Performs linting
- Validates pull requests before merging

This ensures that new code does not break the project.

---

# Key Takeaways

- CI/CD is a development practice that automates software delivery.
- CI catches bugs early by automatically building and testing code.
- Continuous Delivery prepares software for release with manual approval.
- Continuous Deployment automatically releases every successful build.
- Pipelines consist of triggers, stages, jobs, steps, runners, and artifacts.
- Automation improves software quality, consistency, and deployment speed.

---

# Conclusion

Understanding CI/CD concepts before creating pipelines provides a strong foundation for DevOps automation. These practices help teams deliver software faster, reduce human errors, and maintain reliable deployments.

---

## 🚀 Next Step

The next challenge will focus on creating your first CI pipeline using GitHub Actions.
