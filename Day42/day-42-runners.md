# Day 42 – GitHub Actions Runners (GitHub-Hosted & Self-Hosted)

## 📖 Overview

On **Day 42** of the **90 Days of DevOps** challenge, I learned about **GitHub Actions Runners**—the machines responsible for executing GitHub Actions workflows. I explored both **GitHub-hosted** and **self-hosted** runners, examined the tools pre-installed on GitHub-hosted runners, and configured a self-hosted runner to execute workflows on my own machine.

---

## 🎯 Learning Objectives

- Understand what GitHub Actions runners are.
- Learn the difference between GitHub-hosted and self-hosted runners.
- Explore the software pre-installed on GitHub-hosted runners.
- Configure a self-hosted runner.
- Execute workflows using a self-hosted runner.
- Use custom labels to target specific runners.
- Compare GitHub-hosted and self-hosted runners.

---

## 🛠️ Tasks Completed

### ✅ Task 1: GitHub-Hosted Runners

Created a workflow with **three jobs** running in parallel on:

- Ubuntu (`ubuntu-latest`)
- Windows (`windows-latest`)
- macOS (`macos-latest`)

Each job printed:

- Operating System
- Runner Hostname
- Current User

### Key Learning

GitHub-hosted runners are temporary virtual machines created and managed by GitHub. A fresh runner is provisioned for every workflow execution and automatically removed once the job finishes.

---

### ✅ Task 2: Explore Pre-installed Software

Checked the versions of commonly used development tools already installed on the `ubuntu-latest` runner:

- Docker
- Python
- Node.js
- Git

### Key Learning

GitHub-hosted runners include many pre-installed tools, which helps reduce workflow execution time and simplifies CI/CD pipelines by eliminating the need to install common dependencies.

---

### ✅ Task 3: Set Up a Self-Hosted Runner

Configured a self-hosted runner by:

1. Opening **Repository Settings → Actions → Runners**
2. Selecting **New Self-Hosted Runner**
3. Choosing the appropriate operating system
4. Downloading and configuring the runner
5. Starting the runner

Verified that the runner appeared as **Idle** in the GitHub repository.

---

### ✅ Task 4: Run a Workflow on the Self-Hosted Runner

Created a workflow using:

```yaml
runs-on: self-hosted
```

The workflow performed the following tasks:

- Printed the machine hostname
- Displayed the current working directory
- Created a sample file
- Verified that the file existed after execution

This confirmed that the workflow was executed on my own machine instead of GitHub's infrastructure.

---

### ✅ Task 5: Runner Labels

Added a custom runner label:

```text
my-linux-runner
```

Updated the workflow:

```yaml
runs-on:
  - self-hosted
  - my-linux-runner
```

### Key Learning

Labels allow workflows to target specific self-hosted runners based on operating system, hardware, or custom configurations.

---

### ✅ Task 6: GitHub-Hosted vs Self-Hosted

| Feature | GitHub-Hosted Runner | Self-Hosted Runner |
|----------|----------------------|--------------------|
| Managed By | GitHub | User |
| Infrastructure | GitHub Cloud | User's Machine or Cloud VM |
| Cost | Included with GitHub Actions usage | User pays for hardware or cloud resources |
| Pre-installed Tools | Extensive set of tools | User installs and maintains tools |
| Maintenance | GitHub | User |
| Best For | General CI/CD pipelines | Custom environments, private networks, GPUs, specialized workloads |
| Security Responsibility | GitHub | User |

---

## 📁 Project Structure

```text
2026/
└── day-42/
    ├── README.md
    ├── day-42-runners.md
    └── .github/
        └── workflows/
            ├── github-hosted.yml
            └── self-hosted.yml
```

---

## 📚 Key Takeaways

- Every GitHub Actions workflow requires a runner to execute jobs.
- GitHub-hosted runners are automatically provisioned, maintained, and secured by GitHub.
- Self-hosted runners provide greater flexibility and control over the execution environment.
- Labels make it easy to target specific self-hosted runners.
- Choosing the appropriate runner depends on the project's requirements, infrastructure, and security needs.

---

## 🚀 Outcome

By completing Day 42, I gained practical experience with GitHub Actions runners, learned how workflows are executed on different operating systems, configured a self-hosted runner, and understood when to choose GitHub-hosted or self-hosted runners in real-world DevOps environments.

---

## 📖 Resources

- GitHub Actions Documentation
- GitHub Actions Runner Documentation
- GitHub-Hosted Runner Images Documentation

---

**#90DaysOfDevOps #GitHubActions #DevOps #CI #CD #GitHubHostedRunner #SelfHostedRunner #Automation**
