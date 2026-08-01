# 🚀 Day 47 – Advanced Triggers with GitHub Actions

## 📌 Overview

On **Day 47** of my **#90DaysOfDevOps** journey, I explored **Advanced GitHub Actions Triggers** to build more intelligent and production-ready CI/CD pipelines.

Instead of relying only on `push` events, I learned how to automate workflows using Pull Request events, scheduled cron jobs, path and branch filters, workflow chaining, and external event triggers.

---

## 🎯 Objectives

- Understand Pull Request lifecycle events.
- Validate Pull Requests before merging.
- Schedule workflows using cron expressions.
- Optimize workflow execution with path and branch filters.
- Chain workflows together using `workflow_run`.
- Trigger workflows externally using `repository_dispatch`.

---

## 🛠️ Tasks Completed

### ✅ Task 1 – Pull Request Lifecycle Events

Created a workflow that responds to different Pull Request activities.

#### Events Covered

- `opened`
- `synchronize`
- `reopened`
- `closed`

#### Features

- Prints the event action.
- Displays the Pull Request title.
- Displays the PR author.
- Prints the source and target branches.
- Executes a step only when the Pull Request is merged.

**What I Learned**

Pull Request workflows can respond to different stages of a PR lifecycle, making them useful for validation, notifications, testing, and deployment automation.

---

### ✅ Task 2 – PR Validation Workflow

Built an automated validation workflow for Pull Requests targeting the `main` branch.

#### Validation Checks

##### 📂 File Size Check

- Detects files larger than **1 MB**.
- Fails the workflow if oversized files are found.

##### 🌿 Branch Name Validation

Allowed branch naming conventions:

- `feature/*`
- `fix/*`
- `docs/*`

Invalid branch names cause the workflow to fail.

##### 📝 PR Description Check

- Warns when the Pull Request description is empty.
- Does not fail the workflow.

**What I Learned**

Automated validation helps maintain code quality and ensures contributors follow project standards before merging Pull Requests.

---

### ✅ Task 3 – Scheduled Workflows (Cron)

Created scheduled workflows that execute automatically.

#### Cron Expressions

**Every Monday at 2:30 AM UTC**

```text
30 2 * * 1
```

**Every 6 Hours**

```text
0 */6 * * *
```

#### Features

- Added `workflow_dispatch` for manual execution.
- Prints the cron expression that triggered the workflow.
- Performs a website health check using `curl`.

#### Additional Cron Examples

**Every Weekday at 9:00 AM IST**

```text
30 3 * * 1-5
```

**First Day of Every Month at Midnight (UTC)**

```text
0 0 1 * *
```

#### Why Scheduled Workflows May Be Delayed

- Scheduled workflows run only on the repository's default branch.
- GitHub schedules are **best effort** and may be delayed during periods of high usage.
- Inactive repositories may have scheduled workflows skipped until new activity occurs.

**What I Learned**

Scheduled workflows are useful for automating recurring tasks such as monitoring, backups, cleanup jobs, and health checks.

---

### ✅ Task 4 – Path & Branch Filters

Configured workflows to execute only when required.

#### Branch Filters

- `main`
- `release/*`

#### Path Filters

```text
src/**
app/**
```

#### Ignored Paths

```text
*.md
docs/**
```

#### Benefits

- Prevents unnecessary workflow runs.
- Saves GitHub Actions minutes.
- Improves CI/CD efficiency.

**What I Learned**

Path and branch filters help optimize CI/CD pipelines by preventing unnecessary workflow executions.

---

### ✅ Task 5 – Workflow Chaining (`workflow_run`)

Implemented workflow chaining where deployment begins only after testing completes successfully.

#### Workflow Flow

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

#### How It Works

- `tests.yml` runs whenever code is pushed.
- `deploy-after-tests.yml` is triggered after the test workflow completes.
- Deployment proceeds only if the test workflow concludes successfully.

#### `workflow_run` vs `workflow_call`

| `workflow_run` | `workflow_call` |
|----------------|-----------------|
| Triggers one workflow after another finishes. | Calls a reusable workflow from another workflow. |
| Used to chain separate workflows. | Used to reuse common workflow logic. |
| Ideal for CI → CD pipelines. | Ideal for reducing duplicated workflow code. |

**What I Learned**

Separating testing and deployment into different workflows creates a cleaner, more maintainable CI/CD pipeline.

---

### ✅ Task 6 – External Event Trigger (`repository_dispatch`)

Created a workflow that can be triggered by external systems.

#### Event Type

```text
deploy-request
```

#### Sample Payload

```json
{
  "environment": "production"
}
```

The workflow reads the payload using:

```yaml
${{ github.event.client_payload.environment }}
```

#### Real-World Use Cases

- Slack Bot
- Jenkins
- AWS Lambda
- Monitoring Tools
- Internal Deployment Portals

**What I Learned**

`repository_dispatch` enables external systems to communicate with GitHub Actions through the GitHub REST API and custom payloads.

---

## 📂 Workflow Files

| Workflow | Purpose |
|----------|---------|
| `pr-lifecycle.yml` | Handles Pull Request lifecycle events |
| `pr-checks.yml` | Validates Pull Requests before merging |
| `scheduled-tasks.yml` | Executes workflows on a schedule |
| `smart-triggers.yml` | Runs workflows only for specific paths and branches |
| `ignore-docs.yml` | Skips workflow when only documentation changes |
| `tests.yml` | Runs tests on every push |
| `deploy-after-tests.yml` | Deploys after successful test execution |
| `external-trigger.yml` | Handles external API-triggered workflows |

---

## 📚 Key Concepts Learned

- Pull Request lifecycle events
- Pull Request validation
- Cron scheduling
- Manual workflow execution
- Path filters
- Path ignore filters
- Branch filters
- Workflow chaining
- External workflow triggers
- GitHub Actions context variables

---

## 🔄 `workflow_run` vs `workflow_call`

| `workflow_run` | `workflow_call` |
|----------------|-----------------|
| Triggers a workflow after another workflow completes | Calls a reusable workflow from another workflow |
| Used for workflow chaining | Used for workflow reuse |
| Best suited for CI → CD pipelines | Best suited for reducing duplicate workflow logic |

---

## 🎯 Key Takeaways

- Learned advanced GitHub Actions triggers.
- Automated Pull Request validation.
- Scheduled workflows using cron expressions.
- Optimized workflow execution with filters.
- Chained workflows using `workflow_run`.
- Triggered workflows from external systems using `repository_dispatch`.
- Improved understanding of production-ready CI/CD automation.

---

## 📖 Conclusion

Day 47 focused on building smarter GitHub Actions workflows using advanced triggers. These features help create efficient, maintainable, and scalable CI/CD pipelines by responding to Pull Request events, scheduled tasks, file changes, workflow dependencies, and external systems.

This knowledge is widely used in real-world DevOps environments to automate software delivery while maintaining code quality and deployment reliability.

---

## 🏷️ Tags

`GitHub Actions` • `CI/CD` • `DevOps` • `Automation` • `Pull Requests` • `Cron Jobs` • `workflow_run` • `repository_dispatch` • `GitHub`
