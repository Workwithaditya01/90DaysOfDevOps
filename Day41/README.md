# 🚀 Day 41 – Triggers & Matrix Builds

Welcome to **Day 41** of my **#90DaysOfDevOps** journey! 🎉

Today, I explored the different ways to trigger GitHub Actions workflows and learned how to use **Matrix Builds** to execute the same workflow across multiple operating systems and Python versions simultaneously.

---

## 📖 Overview

GitHub Actions provides several ways to automate workflows based on different events. In this challenge, I created workflows that can be triggered by:

- 🔀 Pull Requests
- ⏰ Scheduled Events (Cron Jobs)
- 🖱️ Manual Execution
- 🧩 Matrix Strategy for Multiple Environments

These features help automate testing, deployments, and other CI/CD tasks across different platforms.

---

## 🎯 Learning Objectives

- Understand GitHub Actions workflow triggers
- Trigger workflows on Pull Requests
- Schedule workflows using Cron syntax
- Run workflows manually with `workflow_dispatch`
- Execute jobs across multiple operating systems and Python versions
- Exclude unwanted matrix combinations
- Learn the difference between `fail-fast: true` and `fail-fast: false`

---

## 📂 Project Structure

```text
day-41/
├── README.md
├── day-41-triggers.md
└── .github/
    └── workflows/
        ├── pr-check.yml
        ├── manual.yml
        └── matrix.yml
```

---

## 🛠️ Workflows Created

### 1️⃣ Pull Request Workflow (`pr-check.yml`)

Runs automatically whenever a Pull Request is:

- Opened
- Updated with new commits
- Reopened

The workflow prints the source branch name and validates that the Pull Request targets the `main` branch.

---

### 2️⃣ Scheduled Workflow

Uses GitHub's **schedule** event with a Cron expression.

```yaml
schedule:
  - cron: '0 0 * * *'
```

Runs automatically every day at **12:00 AM UTC**.

---

### 3️⃣ Manual Workflow (`manual.yml`)

Uses the `workflow_dispatch` event to allow manual execution from the **GitHub Actions** page.

It accepts an input parameter:

- `staging`
- `production`

and prints the selected environment during execution.

---

### 4️⃣ Matrix Build (`matrix.yml`)

Runs the same workflow using:

### Operating Systems

- Ubuntu Latest
- Windows Latest

### Python Versions

- Python 3.10
- Python 3.11
- Python 3.12

This allows testing the application across multiple environments simultaneously.

---

## 📊 Matrix Build

Without exclusions:

| Operating System | Python Version |
|------------------|----------------|
| Ubuntu | 3.10 |
| Ubuntu | 3.11 |
| Ubuntu | 3.12 |
| Windows | 3.10 |
| Windows | 3.11 |
| Windows | 3.12 |

Total Jobs:

```
6 Jobs
```

---

### Excluded Combination

```yaml
exclude:
  - os: windows-latest
    python-version: "3.10"
```

Remaining Jobs:

```
5 Jobs
```

---

## ⚡ Fail-Fast

GitHub Actions supports two behaviors for matrix builds.

### `fail-fast: true` (Default)

- Stops remaining matrix jobs if one job fails.
- Saves execution time and GitHub Actions minutes.

### `fail-fast: false`

- Continues running all matrix jobs even if one fails.
- Useful for identifying issues across all environments in a single workflow run.

---

## 📸 Screenshots

Include the following screenshots inside the repository:

- Pull Request workflow execution
- Manual workflow execution
- Scheduled workflow (if available)
- Matrix Build running in parallel
- Workflow summary
- Job logs showing Python versions

---

## 📚 Key Concepts Learned

- GitHub Actions Events
- Pull Request Triggers
- Scheduled Workflows
- Manual Workflow Dispatch
- Cron Expressions
- Matrix Strategy
- Parallel Job Execution
- Multi-Platform Testing
- Exclude Matrix Combinations
- Fail-Fast Strategy

---

## 🏆 Conclusion

Day 41 introduced some of the most powerful features of GitHub Actions. By learning different workflow triggers and Matrix Builds, I can now automate workflows more effectively and validate my projects across multiple operating systems and Python versions. These concepts are essential for building reliable and scalable CI/CD pipelines.

## 🙏 Acknowledgements

A huge thank you to **Shubham Londhe** for designing the **#90DaysOfDevOps** challenge and providing practical, hands-on learning that strengthens real-world DevOps skills.

---

⭐ If you found this repository helpful, consider giving it a **Star** and feel free to explore the rest of my **90 Days of DevOps** journey!
