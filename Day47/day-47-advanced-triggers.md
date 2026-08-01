# Day 47 – Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines

## Overview

On Day 47, I explored advanced GitHub Actions triggers that make CI/CD pipelines more intelligent and efficient. Instead of relying only on `push` events, I learned how to automate workflows using Pull Request events, scheduled cron jobs, path and branch filters, chained workflows, and external event triggers.

---

# Task 1 – Pull Request Lifecycle Events

## Objective

Understand how GitHub Actions responds to different Pull Request lifecycle events.

### Events Covered

- `opened`
- `synchronize`
- `reopened`
- `closed`

### Workflow Features

- Prints the event action.
- Displays the Pull Request title.
- Displays the PR author.
- Prints the source branch and target branch.
- Executes a step only when the Pull Request has been merged.

### What I Learned

Pull Request workflows can react to different stages of a PR lifecycle, making them useful for validation, notifications, testing, and deployment automation.

---

# Task 2 – PR Validation Workflow

## Objective

Automatically validate Pull Requests before they are merged into the `main` branch.

### Validation Checks

#### File Size Check

- Checks repository files.
- Fails the workflow if any file exceeds **1 MB**.

#### Branch Name Check

Allowed branch naming conventions:

- `feature/*`
- `fix/*`
- `docs/*`

The workflow fails if the branch name does not follow these patterns.

#### Pull Request Description Check

- Checks whether the PR description is empty.
- Displays a warning if no description is provided.
- Does not fail the workflow.

### What I Learned

Automated validation helps maintain code quality and ensures contributors follow project standards before merging Pull Requests.

---

# Task 3 – Scheduled Workflows (Cron)

## Objective

Run GitHub Actions workflows automatically at scheduled times.

### Cron Expressions Used

#### Every Monday at 2:30 AM UTC

```text
30 2 * * 1
```

#### Every 6 Hours

```text
0 */6 * * *
```

### Manual Trigger

Added `workflow_dispatch` to manually execute the workflow without waiting for the scheduled time.

### Health Check

Used `curl` to verify a website's availability by checking its HTTP response status code.

### Additional Cron Expressions

#### Every Weekday at 9:00 AM IST

```text
30 3 * * 1-5
```

#### First Day of Every Month at Midnight (UTC)

```text
0 0 1 * *
```

### Why Scheduled Workflows May Be Delayed

- Scheduled workflows only run on the default branch.
- GitHub schedules are best-effort and may be delayed during periods of high usage.
- Inactive repositories may have scheduled workflows skipped until new activity occurs.

### What I Learned

Scheduled workflows are useful for automating recurring tasks such as monitoring, backups, cleanup jobs, and health checks.

---

# Task 4 – Path & Branch Filters

## Objective

Run workflows only when relevant files or branches are affected.

### Path Filters

Workflow runs only when changes occur inside:

```text
src/**
app/**
```

### Path Ignore

Workflow skips execution when only documentation files are modified.

Ignored paths:

```text
*.md
docs/**
```

### Branch Filters

Workflow runs only on:

- `main`
- `release/*`

### Paths vs Paths-Ignore

#### Use `paths`

Use `paths` when a workflow should run only if specific files or directories change.

Examples:

- Application source code
- Infrastructure files
- Configuration files

#### Use `paths-ignore`

Use `paths-ignore` when certain files should not trigger a workflow.

Examples:

- Documentation
- Markdown files
- Images

### What I Learned

Path and branch filters help optimize CI/CD pipelines by preventing unnecessary workflow executions.

---

# Task 5 – Chaining Workflows Using `workflow_run`

## Objective

Automatically trigger one workflow after another workflow completes successfully.

### Workflow Flow

```text
Push
   │
   ▼
Run Tests
   │
   ▼
Tests Successful?
   │
 ┌─┴────────┐
 │          │
Yes         No
 │          │
 ▼          ▼
Deploy     Skip Deployment
```

### How It Works

- `tests.yml` runs whenever code is pushed.
- `deploy-after-tests.yml` is triggered after the test workflow completes.
- Deployment proceeds only if the test workflow concludes successfully.

### `workflow_run` vs `workflow_call`

| workflow_run | workflow_call |
|--------------|---------------|
| Triggers one workflow after another finishes. | Calls a reusable workflow from another workflow. |
| Used to chain separate workflows. | Used to reuse common workflow logic. |
| Ideal for CI → CD pipelines. | Ideal for reducing duplicated workflow code. |

### What I Learned

Separating testing and deployment into different workflows creates a cleaner, more maintainable CI/CD pipeline.

---

# Task 6 – External Event Trigger (`repository_dispatch`)

## Objective

Trigger GitHub Actions workflows from external applications or services.

### Event Type

```text
deploy-request
```

### Example Payload

```json
{
  "environment": "production"
}
```

The workflow reads the payload using:

```yaml
${{ github.event.client_payload.environment }}
```

### Real-World Use Cases

- Slack bot triggers a deployment.
- Monitoring tools start recovery workflows.
- Jenkins triggers GitHub Actions.
- AWS Lambda starts automation.
- Internal deployment portals initiate releases.

### What I Learned

`repository_dispatch` enables external systems to communicate with GitHub Actions through the GitHub REST API and custom payloads.

---

# Key Takeaways

- Learned how Pull Request lifecycle events work.
- Built automated PR validation workflows.
- Scheduled workflows using cron expressions.
- Optimized workflow execution with path and branch filters.
- Chained workflows using `workflow_run`.
- Triggered workflows externally using `repository_dispatch`.
- Understood the difference between `workflow_run` and `workflow_call`.

---

# Conclusion

Day 47 introduced advanced GitHub Actions triggers that improve automation and pipeline efficiency. By combining Pull Request events, scheduled workflows, smart path filters, workflow chaining, and external triggers, I gained a deeper understanding of how modern DevOps teams build scalable and production-ready CI/CD pipelines.
