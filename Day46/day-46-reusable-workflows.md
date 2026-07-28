# Day 46 – Reusable Workflows & Composite Actions

## Objective

The goal of this exercise was to learn how to eliminate duplicate GitHub Actions workflows by creating reusable workflows using `workflow_call` and custom composite actions. These features are commonly used in production environments to standardize CI/CD pipelines across multiple repositories.

---

# Task 1: Understanding Reusable Workflows

## What is a Reusable Workflow?

A reusable workflow is a GitHub Actions workflow that can be called by another workflow using the `workflow_call` trigger. Instead of writing the same CI/CD logic in multiple repositories, the workflow is written once and reused wherever needed.

---

## What is the `workflow_call` Trigger?

The `workflow_call` trigger allows one workflow to invoke another workflow.

Unlike triggers such as:

- `push`
- `pull_request`
- `workflow_dispatch`

a reusable workflow cannot be executed directly. It only runs when another workflow calls it.

### Example

```text
Caller Workflow
        │
        ▼
Reusable Workflow
```

---

## Reusable Workflow vs Regular Action

| Reusable Workflow | Regular Action |
|-------------------|---------------|
| Contains one or more jobs | Contains reusable steps |
| Triggered using `workflow_call` | Used with `uses:` |
| Can run on different runners | Runs inside the current job |
| Can define workflow outputs | Mainly provides reusable step logic |

---

## Where Must a Reusable Workflow Live?

Reusable workflows must be stored inside the GitHub Actions workflows directory so they can be discovered and called by other workflows.

---

# Task 2: Reusable Workflow

Created a reusable workflow that:

- Uses the `workflow_call` trigger
- Accepts input parameters:
  - `app_name`
  - `environment`
- Accepts a required secret:
  - `docker_token`
- Generates a build version
- Returns the generated version as a workflow output

### Features

- Reusable across multiple workflows
- Supports inputs and secrets
- Produces outputs for downstream jobs

---

# Task 3: Caller Workflow

Created a caller workflow that:

- Runs whenever code is pushed to the `main` branch
- Calls the reusable workflow
- Passes:
  - Application name
  - Environment
  - Docker token secret

### Workflow Flow

```text
Push to Main
      │
      ▼
Caller Workflow
      │
      ▼
Reusable Workflow
      │
      ▼
Generate Build Version
```

---

# Task 4: Workflow Outputs

The reusable workflow generates a version string using the current commit SHA.

### Example Output

```text
v1.0-a1b2c3d
```

The output flows through three levels:

- Step Output
- Job Output
- Workflow Output

The caller workflow then reads the generated version and prints it in a separate job.

---

# Task 5: Composite Action

Created a custom Composite Action that:

- Accepts user inputs
- Prints a greeting
- Displays the current date
- Displays the runner operating system
- Returns an output named:

```text
greeted=true
```

The composite action is then used inside another workflow using the `uses:` keyword.

---

# Reusable Workflow vs Composite Action

| Feature | Reusable Workflow | Composite Action |
|----------|-------------------|------------------|
| Triggered By | `workflow_call` | `uses:` inside a step |
| Can Contain Jobs | ✅ Yes | ❌ No |
| Can Contain Multiple Steps | ✅ Yes | ✅ Yes |
| Runner | Uses its own runner | Uses the caller's runner |
| Accepts Secrets Directly | ✅ Yes | ❌ No |
| Best Used For | Complete CI/CD pipelines | Reusable groups of steps |

---

# Workflow Architecture

```text
Caller Workflow
      │
      ▼
Reusable Workflow
      │
      ├── Checkout Repository
      ├── Read Inputs
      ├── Read Secrets
      ├── Generate Build Version
      └── Return Output
              │
              ▼
Caller Workflow
      │
      ▼
Print Build Version
```

---

# Composite Action Flow

```text
Workflow
     │
     ▼
Composite Action
     │
     ├── Print Greeting
     ├── Print Date
     ├── Print Runner OS
     └── Return Output
```

---

# Key Learnings

- Learned how reusable workflows reduce duplicate CI/CD code.
- Understood the purpose of the `workflow_call` trigger.
- Passed inputs and secrets between workflows.
- Generated and consumed workflow outputs.
- Built and used a custom Composite Action.
- Learned the differences between reusable workflows and composite actions.
- Improved workflow modularity, maintainability, and reusability.

---

# Conclusion

Reusable Workflows and Composite Actions are powerful GitHub Actions features that promote code reuse and consistency across projects. Reusable workflows are ideal for sharing complete CI/CD pipelines, while Composite Actions are best suited for grouping commonly used steps into reusable building blocks. Mastering both approaches helps create cleaner, more scalable, and production-ready automation workflows.
