# Day 43 – Jobs, Steps, Environment Variables & Conditionals

**Date:** 23 July 2026

## 🎯 Objective

Today I learned how to control the execution flow of GitHub Actions workflows using:

- Multiple Jobs
- Job Dependencies
- Environment Variables
- Job Outputs
- Conditional Execution
- GitHub Context Variables

---

# Task 1 – Multi-Job Workflow

## Goal

Create a workflow containing three jobs:

- Build
- Test
- Deploy

Each job should execute only after the previous one completes successfully.

---

## Workflow

**File: `.github/workflows/multi-job.yml`**

```yaml
name: Multi Job Workflow

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Build
        run: echo "Building the app"

  test:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Test
        run: echo "Running tests"

  deploy:
    runs-on: ubuntu-latest
    needs: test

    steps:
      - name: Deploy
        run: echo "Deploying"
```

---

## Explanation

### Job Dependency

The `needs` keyword creates dependencies between jobs.

```yaml
needs: build
```

means

> Run this job only after the **build** job succeeds.

Our dependency chain becomes:

```
Build
   │
   ▼
Test
   │
   ▼
Deploy
```

---

## Verification

Open the **Actions** tab.

The workflow graph should display:

```
Build
  ↓
Test
  ↓
Deploy
```

---

# Task 2 – Environment Variables

## Goal

Use environment variables at three different levels.

- Workflow Level
- Job Level
- Step Level

Also print GitHub Context variables.

---

## Workflow

**File: `.github/workflows/environment.yml`**

```yaml
name: Environment Variables

on:
  workflow_dispatch:

env:
  APP_NAME: myapp

jobs:
  show-env:
    runs-on: ubuntu-latest

    env:
      ENVIRONMENT: staging

    steps:
      - name: Print Variables
        env:
          VERSION: 1.0.0

        run: |
          echo "App Name: $APP_NAME"
          echo "Environment: $ENVIRONMENT"
          echo "Version: $VERSION"

      - name: GitHub Context
        run: |
          echo "Commit SHA: ${{ github.sha }}"
          echo "Triggered By: ${{ github.actor }}"
```

---

## Variable Levels

### Workflow Level

Available everywhere.

```yaml
env:
  APP_NAME: myapp
```

---

### Job Level

Only available inside that job.

```yaml
jobs:
  demo:
    env:
      ENVIRONMENT: staging
```

---

### Step Level

Only available inside one step.

```yaml
steps:
  - env:
      VERSION: 1.0.0
```

---

## GitHub Context Variables

Useful built-in information.

Examples:

```yaml
${{ github.sha }}
```

Current commit SHA.

```yaml
${{ github.actor }}
```

The user who triggered the workflow.

---

# Task 3 – Job Outputs

## Goal

Pass data from one job to another.

---

## Workflow

**File: `.github/workflows/job-output.yml`**

```yaml
name: Job Outputs

on:
  workflow_dispatch:

jobs:
  generate-date:
    runs-on: ubuntu-latest

    outputs:
      today: ${{ steps.date.outputs.today }}

    steps:
      - id: date
        run: echo "today=$(date)" >> $GITHUB_OUTPUT

  print-date:
    runs-on: ubuntu-latest
    needs: generate-date

    steps:
      - run: echo "Today's Date: ${{ needs.generate-date.outputs.today }}"
```

---

## How It Works

### Step 1

Generate an output.

```bash
echo "today=$(date)" >> $GITHUB_OUTPUT
```

---

### Step 2

Expose it as a job output.

```yaml
outputs:
  today: ${{ steps.date.outputs.today }}
```

---

### Step 3

Read it from another job.

```yaml
${{ needs.generate-date.outputs.today }}
```

---

## Why Pass Outputs Between Jobs?

Job outputs allow one job to share information with another without recalculating it.

Common examples include:

- Docker image tags
- Version numbers
- Build artifacts
- Commit hashes
- Deployment URLs
- Generated file names
- Release versions

This makes workflows cleaner and avoids duplicate work.

---

# Task 4 – Conditionals

## Goal

Run jobs or steps only when specific conditions are true.

---

## Workflow

**File: `.github/workflows/conditionals.yml`**

```yaml
name: Conditionals

on:
  push:
  pull_request:

jobs:
  demo:
    runs-on: ubuntu-latest

    steps:
      - name: Success Step
        run: echo "Running..."

      - name: Run only on Main
        if: github.ref == 'refs/heads/main'
        run: echo "This is the main branch."

      - name: Intentional Failure
        continue-on-error: true
        run: exit 1

      - name: Runs if Previous Step Failed
        if: failure()
        run: echo "Previous step failed."

  push-only:
    if: github.event_name == 'push'

    runs-on: ubuntu-latest

    steps:
      - run: echo "This job only runs on push."
```

---

## Important Conditionals

### Run only on Main

```yaml
if: github.ref == 'refs/heads/main'
```

---

### Run when previous step failed

```yaml
if: failure()
```

---

### Run only on Push

```yaml
if: github.event_name == 'push'
```

---

### Continue on Error

```yaml
continue-on-error: true
```

If this step fails, the workflow continues instead of stopping.

Useful for:

- Experimental tests
- Optional checks
- Code coverage
- Non-blocking tasks

---

# Task 5 – Smart Pipeline

## Goal

Create a smarter workflow that runs jobs in parallel and summarizes the results.

---

## Workflow

**File: `.github/workflows/smart-pipeline.yml`**

```yaml
name: Smart Pipeline

on:
  push:

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - run: echo "Running Lint..."

  test:
    runs-on: ubuntu-latest

    steps:
      - run: echo "Running Tests..."

  summary:
    runs-on: ubuntu-latest

    needs:
      - lint
      - test

    steps:
      - name: Branch Type
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "Main Branch Push"
          else
            echo "Feature Branch Push"
          fi

      - name: Commit Message
        run: echo "${{ github.event.commits[0].message }}"
```

---

## Workflow Flow

```
             Push

        ┌────────────┐
        │            │
        ▼            ▼

      Lint        Test

        └──────┬─────┘
               ▼

          Summary Job
```

---

# Key Concepts Learned

## Jobs

Jobs are independent units of work.

Each job runs on its own runner.

---

## Steps

Steps are individual tasks executed sequentially inside a job.

---

## Environment Variables

Environment variables help avoid hardcoding values and make workflows reusable.

They can be defined at:

- Workflow level
- Job level
- Step level

---

## needs

`needs` creates dependencies between jobs.

It ensures jobs execute in the required order and allows sharing outputs.

---

## outputs

Outputs allow one job to send data to another job.

This is useful for passing values like versions, timestamps, image tags, or deployment URLs without repeating work.

---

## Conditionals

Conditionals let workflows make decisions based on events, branches, or previous step results.

Examples include:

- Running only on the `main` branch
- Running only on `push`
- Executing steps after failures
- Allowing optional steps with `continue-on-error`

---

# What I Learned Today

- Created multi-job workflows.
- Controlled execution order using `needs`.
- Used workflow, job, and step-level environment variables.
- Accessed GitHub context variables like actor and commit SHA.
- Passed outputs between jobs.
- Used conditional expressions to control workflow execution.
- Built a smart pipeline with parallel jobs and a summary stage.

---

# Repository Structure

```
.github/
└── workflows/
    ├── multi-job.yml
    ├── environment.yml
    ├── job-output.yml
    ├── conditionals.yml
    └── smart-pipeline.yml

2026/
└── day-43/
    └── day-43-jobs-steps.md
```

---

# Conclusion

Day 43 introduced workflow orchestration in GitHub Actions. By combining multiple jobs, dependencies, environment variables, outputs, and conditional execution, I can now design more structured and efficient CI/CD pipelines that are easier to maintain and scale.
