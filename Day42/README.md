# Day 42 – GitHub Actions Runners (GitHub-Hosted & Self-Hosted)

Welcome to **Day 42** of my **90 Days of DevOps** journey! 🚀

Today, I explored **GitHub Actions Runners**, the machines responsible for executing GitHub Actions workflows. I learned the differences between **GitHub-hosted** and **self-hosted** runners, explored the software available on GitHub-hosted runners, and configured a self-hosted runner to run workflows on my own machine.

---

## 📌 Topics Covered

- Introduction to GitHub Actions Runners
- GitHub-Hosted Runners
- Self-Hosted Runners
- Runner Labels
- Pre-installed Software on GitHub Runners
- Running Workflows on Different Operating Systems
- GitHub-Hosted vs Self-Hosted Comparison

---

## 📂 Project Structure

```text
day-42/
├── README.md
├── day-42-runners.md
└── .github/
    └── workflows/
        ├── github-hosted.yml
        └── self-hosted.yml
```

---

## 📝 Tasks Completed

### ✅ Task 1 – GitHub-Hosted Runners

Created a workflow that runs simultaneously on:

- Ubuntu (`ubuntu-latest`)
- Windows (`windows-latest`)
- macOS (`macos-latest`)

Each job prints:

- Operating System
- Hostname
- Current User

---

### ✅ Task 2 – Explore Pre-installed Software

Verified the versions of:

- Docker
- Python
- Node.js
- Git

This demonstrates that GitHub-hosted runners already include many commonly used development tools.

---

### ✅ Task 3 – Configure a Self-Hosted Runner

Configured a self-hosted runner by:

- Registering it with the GitHub repository
- Downloading the runner package
- Configuring the runner
- Starting the runner
- Verifying that it appeared as **Idle** in GitHub

---

### ✅ Task 4 – Execute a Workflow on a Self-Hosted Runner

Created a workflow using:

```yaml
runs-on: self-hosted
```

The workflow:

- Displays the hostname
- Prints the working directory
- Creates a sample file
- Verifies that the file exists after execution

This confirms that the workflow is executed on the local machine instead of GitHub-hosted infrastructure.

---

### ✅ Task 5 – Using Runner Labels

Added a custom label:

```text
my-linux-runner
```

Updated the workflow:

```yaml
runs-on:
  - self-hosted
  - my-linux-runner
```

Labels allow workflows to target specific self-hosted runners when multiple runners are available.

---

### ✅ Task 6 – GitHub-Hosted vs Self-Hosted

| Feature | GitHub-Hosted | Self-Hosted |
|----------|---------------|-------------|
| Managed By | GitHub | User |
| Infrastructure | GitHub Cloud | User's Machine or Cloud VM |
| Cost | Included with GitHub Actions usage | User pays for infrastructure |
| Pre-installed Tools | Extensive collection | User managed |
| Maintenance | GitHub | User |
| Best For | General CI/CD workloads | Custom environments, private networks, GPUs |
| Security Responsibility | GitHub | User |

---

## 📚 Key Learnings

- Every GitHub Actions workflow runs on a **runner**.
- GitHub-hosted runners are temporary virtual machines managed by GitHub.
- Self-hosted runners execute workflows on your own machine or server.
- Runner labels help target specific machines.
- Self-hosted runners provide more flexibility and control but require maintenance and security management.

---

## 🚀 Outcome

By completing Day 42, I learned how GitHub Actions workflows are executed, configured a self-hosted runner, used runner labels for workflow targeting, and understood the practical differences between GitHub-hosted and self-hosted runners.

---

## 📖 References

- GitHub Actions Documentation
- GitHub Actions Runner Documentation
- GitHub-Hosted Runner Images Documentation

---

### ⭐ If you found this repository helpful, consider giving it a star!

## 🔖 Hashtags

`#90DaysOfDevOps` `#GitHubActions` `#DevOps` `#CI` `#CD` `#Automation` `#SelfHostedRunner` `#GitHubHostedRunner`
