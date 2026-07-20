# Day 41 – Triggers & Matrix Builds

> **Challenge:** Learn different ways to trigger GitHub Actions workflows and run jobs across multiple environments using Matrix Builds.

---

# 📌 Objective

On Day 41, I explored different workflow triggers available in GitHub Actions and learned how to execute the same workflow across multiple operating systems and Python versions using Matrix Builds.

---

# 📚 Learning Outcomes

- Understand different GitHub Actions triggers
- Create workflows that run on Pull Requests
- Schedule workflows using Cron expressions
- Run workflows manually using `workflow_dispatch`
- Execute jobs across multiple environments using Matrix Strategy
- Exclude specific matrix combinations
- Understand the difference between `fail-fast: true` and `fail-fast: false`

---

# Task 1 – Pull Request Trigger

## Objective

Run a workflow automatically whenever a Pull Request is opened or updated against the `main` branch.

---

## Workflow

```yaml
name: Pull Request Check

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize
      - reopened

jobs:
  pr-check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Print Branch Name
        run: echo "PR check running for branch: ${{ github.head_ref }}"
```

---

## Steps Performed

- Created a new feature branch
- Added a commit
- Pushed the branch to GitHub
- Opened a Pull Request targeting `main`
- Observed the workflow running automatically

---

## Output

```
PR check running for branch: feature/pr-test
```

---

## Screenshot

> 📷 Add screenshot of the Pull Request workflow execution here.

---

# Task 2 – Scheduled Trigger

## Objective

Run a workflow automatically every day using Cron syntax.

---

## Workflow

```yaml
name: Daily Schedule

on:
  schedule:
    - cron: '0 0 * * *'

jobs:
  daily-job:
    runs-on: ubuntu-latest

    steps:
      - run: echo "Running every midnight UTC"
```

---

## Cron Expression

```
0 0 * * *
```

Meaning

| Field | Value |
|--------|-------|
| Minute | 0 |
| Hour | 0 |
| Day | Every Day |
| Month | Every Month |
| Weekday | Every Weekday |

This workflow runs **every day at 12:00 AM UTC**.

---

## Challenge Question

### What is the Cron expression for every Monday at 9:00 AM UTC?

```
0 9 * * 1
```

---

# Task 3 – Manual Trigger

## Objective

Trigger a workflow manually from the GitHub Actions page.

---

## Workflow

```yaml
name: Manual Workflow

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Choose Environment"
        required: true
        default: "staging"
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Print Environment
        run: echo "Selected Environment: ${{ github.event.inputs.environment }}"
```

---

## Steps Performed

- Opened the **Actions** tab
- Selected **Manual Workflow**
- Clicked **Run workflow**
- Selected an environment
- Executed the workflow

---

## Output

```
Selected Environment: staging
```

---

## Screenshot

> 📷 Add screenshot of the manual workflow execution here.

---

# Task 4 – Matrix Builds

## Objective

Run the same workflow using multiple Python versions and Operating Systems.

---

## Workflow

```yaml
name: Matrix Build

on:
  workflow_dispatch:

jobs:
  matrix-build:
    runs-on: ${{ matrix.os }}

    strategy:
      fail-fast: false

      matrix:
        os:
          - ubuntu-latest
          - windows-latest

        python-version:
          - "3.10"
          - "3.11"
          - "3.12"

        exclude:
          - os: windows-latest
            python-version: "3.10"

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Show Python Version
        run: python --version
```

---

## Matrix Combinations

| Operating System | Python Version |
|------------------|----------------|
| Ubuntu | 3.10 |
| Ubuntu | 3.11 |
| Ubuntu | 3.12 |
| Windows | 3.11 |
| Windows | 3.12 |

---

## Total Jobs

Without exclusion:

```
2 × 3 = 6 Jobs
```

Excluded Combination:

```
Windows + Python 3.10
```

Final Total:

```
5 Jobs
```

---

## Screenshot

> 📷 Add screenshot showing multiple jobs running in parallel.

---

# Task 5 – Exclude & Fail-Fast

## Exclude

```yaml
exclude:
  - os: windows-latest
    python-version: "3.10"
```

The excluded job will never run.

---

## Fail Fast

```yaml
strategy:
  fail-fast: false
```

### fail-fast: true (Default)

- If one matrix job fails, GitHub cancels all remaining running or queued jobs.

### fail-fast: false

- Even if one job fails, all other matrix jobs continue until completion.

This helps identify issues across all environments in a single workflow run.

---

# Key Concepts Learned

- `push`
- `pull_request`
- `schedule`
- `workflow_dispatch`
- Cron expressions
- Matrix Strategy
- Multiple Operating Systems
- Multiple Python Versions
- Exclude Matrix Combinations
- Parallel Job Execution
- Fail Fast Behavior

---

# Repository Structure

```
.github/
└── workflows/
    ├── pr-check.yml
    ├── manual.yml
    ├── matrix.yml

2026/
└── day-41/
    └── day-41-triggers.md
```

---

# Conclusion

Day 41 introduced the powerful triggering mechanisms available in GitHub Actions. I learned how to automate workflows based on Pull Requests, scheduled events, and manual executions. I also explored Matrix Builds, which allow the same workflow to run across multiple operating systems and Python versions simultaneously. Finally, I understood how to optimize matrix executions using `exclude` and `fail-fast`, making CI pipelines more efficient and easier to debug.

---

# Screenshots to Include

- ✅ Pull Request workflow run
- ✅ Scheduled workflow (if executed)
- ✅ Manual workflow execution
- ✅ Matrix build showing parallel jobs
- ✅ Matrix job summary after exclusion
- ✅ Workflow logs showing Python versions

---

## 📖 References

- https://docs.github.com/en/actions
- https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows
- https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs
- https://crontab.guru/
