i# 🚀 Day 40 – Your First GitHub Actions Workflow

## 📖 Overview

On Day 40, I created my first GitHub Actions workflow to understand how Continuous Integration (CI) works in GitHub. The workflow automatically runs whenever code is pushed to the repository, demonstrating the basics of automation using GitHub-hosted runners.

---

# 🎯 Objectives

- Learn what GitHub Actions is.
- Create and run a basic workflow.
- Understand the structure of a workflow file.
- Execute shell commands on a GitHub-hosted runner.
- Use GitHub context variables.
- Learn how to debug workflow failures.

---

# 📁 Repository Structure

```text
github-actions-practice
│
├── README.md
│
└── .github
    └── workflows
        └── hello.yml
```

---

# 🛠️ Task 1 – Repository Setup

## Steps Performed

1. Created a new public GitHub repository named **github-actions-practice**.
2. Cloned the repository locally.
3. Created the required GitHub Actions directory structure.

### Folder Structure

```text
.github/
└── workflows/
```

---

# 🚀 Task 2 – Creating the First Workflow

Created a workflow file named:

```text
.github/workflows/hello.yml
```

## Workflow Code

```yaml
name: Hello GitHub Actions

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Print Hello
        run: echo "Hello from GitHub Actions!"
```

---

## Workflow Explanation

Whenever code is pushed to the repository:

1. GitHub detects the push event.
2. A fresh Ubuntu virtual machine is created.
3. The repository is checked out.
4. The workflow prints:

```text
Hello from GitHub Actions!
```

If every step completes successfully, GitHub marks the workflow as **Passed** with a green checkmark.

---

# 📚 Task 3 – Understanding Workflow Anatomy

| Keyword | Description |
|----------|-------------|
| `name` | Name displayed for the workflow in the GitHub Actions tab. |
| `on` | Defines which event triggers the workflow. |
| `jobs` | Contains one or more jobs to execute. |
| `runs-on` | Specifies the operating system for the runner. |
| `steps` | Sequence of tasks executed inside a job. |
| `uses` | Executes a reusable GitHub Action. |
| `run` | Executes shell commands on the runner. |
| `name` (step) | Human-readable name shown in the workflow logs. |

---

# ➕ Task 4 – Extending the Workflow

The workflow was updated to perform additional tasks.

## Updated Workflow

```yaml
name: Hello GitHub Actions

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Print Hello
        run: echo "Hello from GitHub Actions!"

      - name: Print Current Date and Time
        run: date

      - name: Print Branch Name
        run: echo "Branch: ${{ github.ref_name }}"

      - name: List Repository Files
        run: ls -la

      - name: Print Runner Operating System
        run: echo "Runner OS: $RUNNER_OS"
```

---

## Expected Output

```text
Hello from GitHub Actions!

Mon Jul 20 10:45:33 UTC

Branch: main

README.md
.github/

Runner OS: Linux
```

---

# ❌ Task 5 – Breaking the Workflow

To understand workflow failures, a step was intentionally added that exits with a non-zero status.

```yaml
- name: Fail Pipeline
  run: exit 1
```

After pushing this change, the workflow failed.

GitHub displayed an error similar to:

```text
Process completed with exit code 1.
```

The failing step was removed, the workflow was pushed again, and the pipeline completed successfully.

---

# 📸 Screenshots

Add screenshots of the following:

- ✅ Green workflow run
- ✅ Workflow summary
- ✅ Job details
- ✅ Individual workflow steps
- ❌ Failed workflow (optional)

Example folder structure:

```text
2026/
└── day-40/
    ├── day-40-first-workflow.md
    └── images/
        ├── green-run.png
        ├── workflow-summary.png
        ├── job-details.png
        └── failed-run.png
```

---

# 📖 Key Learnings

- Understood the purpose of GitHub Actions.
- Learned how workflows are triggered automatically.
- Created and executed a basic CI workflow.
- Learned the meaning of common workflow keywords.
- Used built-in GitHub context variables.
- Executed shell commands on a GitHub-hosted runner.
- Learned how to inspect workflow logs.
- Understood how to identify and fix workflow failures.

---

# 🏁 Conclusion

Day 40 introduced the fundamentals of GitHub Actions and Continuous Integration. By creating, running, extending, intentionally breaking, and fixing a workflow, I gained hands-on experience with automated pipelines. This serves as the foundation for building more advanced CI/CD workflows involving testing, linting, Docker image builds, and application deployments.

---

# 📌 Outcome

- ✅ Created my first GitHub Actions workflow.
- ✅ Triggered workflows on every push.
- ✅ Learned the structure of workflow YAML files.
- ✅ Executed commands on GitHub-hosted runners.
- ✅ Used GitHub context variables.
- ✅ Debugged and fixed a failed pipeline.
- ✅ Successfully completed Day 40 of the **90 Days of DevOps** challenge.

---

## 🔗 References

- GitHub Actions Documentation: https://docs.github.com/en/actions
- GitHub Actions Marketplace: https://github.com/marketplace?type=actions
- actions/checkout: https://github.com/actions/checkout
