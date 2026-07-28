# Day 46 – Reusable Workflows & Composite Actions

This project demonstrates how to create reusable GitHub Actions workflows and custom composite actions to reduce duplication and improve maintainability in CI/CD pipelines.

## Objectives

- Learn how to use the `workflow_call` trigger.
- Create a reusable workflow that accepts inputs and secrets.
- Call a reusable workflow from another workflow.
- Generate and consume workflow outputs.
- Build a custom Composite Action.
- Understand the differences between Reusable Workflows and Composite Actions.

---

## What is a Reusable Workflow?

A reusable workflow is a GitHub Actions workflow that can be invoked by another workflow using the `workflow_call` trigger. It allows you to write common CI/CD logic once and reuse it across multiple workflows or repositories.

### Benefits

- Reduces duplicate workflow code.
- Standardizes CI/CD pipelines.
- Improves maintainability.
- Makes workflows easier to update.

---

## What is a Composite Action?

A Composite Action groups multiple workflow steps into a single reusable action. Unlike reusable workflows, composite actions run inside the caller's job rather than creating a new job.

### Benefits

- Reuse common workflow steps.
- Keep workflows clean and organized.
- Simplify repetitive tasks.

---

## Tasks Completed

### Task 1 – Understanding Reusable Workflows

Learned about:

- Reusable Workflows
- `workflow_call`
- Workflow inputs
- Workflow secrets
- Workflow outputs

---

### Task 2 – Created a Reusable Workflow

Implemented a reusable workflow that:

- Accepts application name as input.
- Accepts deployment environment.
- Accepts a Docker token as a secret.
- Checks out the repository.
- Prints build information.
- Generates a build version.
- Exposes the build version as an output.

---

### Task 3 – Created a Caller Workflow

Created a workflow that:

- Runs on every push to the `main` branch.
- Calls the reusable workflow.
- Passes required inputs.
- Passes repository secrets.

---

### Task 4 – Added Workflow Outputs

Generated a build version using the current commit SHA.

Example:

```text
v1.0-a1b2c3d
```

The generated version is returned from:

- Step Output
- Job Output
- Workflow Output

The caller workflow then reads and displays the generated version.

---

### Task 5 – Created a Composite Action

Built a custom Composite Action that:

- Accepts user inputs.
- Prints a greeting.
- Displays the current date.
- Displays the runner operating system.
- Returns an output indicating successful execution.

---

## Workflow Flow

```text
Push to Main
      │
      ▼
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

## Composite Action Flow

```text
Workflow
     │
     ▼
Composite Action
     │
     ├── Print Greeting
     ├── Print Current Date
     ├── Print Runner OS
     └── Return Output
```

---

## Reusable Workflow vs Composite Action

| Feature | Reusable Workflow | Composite Action |
|---------|-------------------|------------------|
| Trigger | `workflow_call` | `uses:` inside a step |
| Contains Jobs | ✅ Yes | ❌ No |
| Contains Multiple Steps | ✅ Yes | ✅ Yes |
| Runner | Own runner | Uses caller's runner |
| Accepts Secrets Directly | ✅ Yes | ❌ No |
| Best For | Entire CI/CD pipelines | Reusable workflow steps |

---

## Key Concepts Learned

- Reusable Workflows
- `workflow_call`
- Workflow Inputs
- Workflow Secrets
- Workflow Outputs
- Composite Actions
- Job Outputs
- Step Outputs
- Workflow Reusability
- CI/CD Best Practices

---

## Key Takeaways

- Reusable workflows eliminate duplicate workflow definitions.
- Composite actions simplify repetitive workflow steps.
- Outputs enable communication between workflows and jobs.
- Inputs and secrets make workflows flexible and reusable.
- Modular GitHub Actions workflows are easier to maintain and scale.

---

## Conclusion

This project demonstrates how to build modular and reusable GitHub Actions workflows using `workflow_call` and Composite Actions. These features are essential for creating scalable, maintainable, and production-ready CI/CD pipelines while reducing code duplication across repositories.
