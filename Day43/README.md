# Day 43 – Jobs, Steps, Environment Variables & Conditionals

## 📌 Overview

Welcome to **Day 43** of my **90 Days of DevOps** journey!

Today, I explored how to control the execution flow of GitHub Actions workflows by learning about **multiple jobs**, **job dependencies**, **environment variables**, **job outputs**, and **conditional execution**. These features are essential for building organized, scalable, and production-ready CI/CD pipelines.

---

## 🎯 Learning Objectives

- Understand how GitHub Actions workflows are structured.
- Create workflows with multiple jobs.
- Control job execution using the `needs` keyword.
- Use environment variables at different scopes.
- Pass data between jobs using job outputs.
- Execute jobs and steps conditionally.
- Build a smart CI pipeline with parallel jobs.

---

## 📂 Project Structure

```text
.
├── .github
│   └── workflows
│       ├── multi-job.yml
│       ├── environment.yml
│       ├── job-outputs.yml
│       ├── conditionals.yml
│       └── smart-pipeline.yml
│
└── README.md
```

---

# Task 1 – Multi-Job Workflow

## Objective

Create a workflow with three jobs:

- Build
- Test
- Deploy

The workflow uses the `needs` keyword to execute jobs in sequence.

### Workflow

```text
Build
   │
   ▼
Test
   │
   ▼
Deploy
```

### Concepts Learned

- Multiple Jobs
- Job Dependencies
- `needs`
- Workflow Graph

---

# Task 2 – Environment Variables

## Objective

Learn how to define and use environment variables at different levels.

### Environment Variable Levels

| Level | Scope |
|-------|-------|
| Workflow | Available to every job and every step |
| Job | Available only inside that job |
| Step | Available only inside that step |

### GitHub Context Variables Used

- `github.sha`
- `github.actor`
- `github.repository`
- `github.ref_name`

### Concepts Learned

- Workflow-level variables
- Job-level variables
- Step-level variables
- GitHub Context

---

# Task 3 – Job Outputs

## Objective

Pass information from one job to another.

### Workflow

```text
Generate Date
      │
      ▼
 Job Output
      │
      ▼
 Print Date
```

### Concepts Learned

- `$GITHUB_OUTPUT`
- Step Outputs
- Job Outputs
- Reading outputs using `needs`

---

# Task 4 – Conditionals

## Objective

Run jobs or steps only when specific conditions are met.

### Conditions Implemented

- Run only on the `main` branch.
- Run a step only if a previous step fails.
- Run a job only on `push` events.
- Continue workflow execution even if a step fails.

### Concepts Learned

- `if`
- `failure()`
- `continue-on-error`
- `github.ref`
- `github.event_name`

---

# Task 5 – Smart Pipeline

## Objective

Combine everything learned into a single workflow.

### Workflow

```text
                Push
                  │
      ┌───────────┴───────────┐
      │                       │
      ▼                       ▼

    Lint Job              Test Job
      │                       │
      └───────────┬───────────┘
                  │
                  ▼

             Summary Job
                  │
        ┌─────────┴─────────┐
        ▼                   ▼

 Branch Information   Commit Message
```

### Concepts Learned

- Parallel Jobs
- Job Dependencies
- GitHub Context
- Branch Detection
- Commit Information

---

# Key GitHub Actions Concepts

## Jobs

A **job** is a collection of steps that run on a GitHub-hosted or self-hosted runner.

Each job runs on its own fresh virtual machine.

---

## Steps

Steps are individual tasks inside a job.

Examples include:

- Running shell commands
- Installing dependencies
- Executing tests
- Building applications

---

## `needs`

The `needs` keyword creates dependencies between jobs.

Example:

```yaml
needs: build
```

This tells GitHub Actions to wait until the `build` job completes successfully before starting the next job.

---

## Environment Variables

Environment variables allow workflows to reuse values without hardcoding them.

They can be defined at:

- Workflow level
- Job level
- Step level

---

## Job Outputs

Job outputs allow one job to pass information to another.

Common use cases include:

- Docker image tags
- Version numbers
- Build artifacts
- Deployment URLs
- Generated timestamps

---

## Conditionals

Conditionals allow workflows to make decisions during execution.

Examples include:

- Run only on the `main` branch
- Run only after failures
- Run only for specific GitHub events
- Continue even if a step fails

---

# Files Created

| File | Description |
|------|-------------|
| `multi-job.yml` | Demonstrates multiple jobs with dependencies. |
| `environment.yml` | Demonstrates workflow, job, and step-level environment variables. |
| `job-outputs.yml` | Demonstrates passing outputs between jobs. |
| `conditionals.yml` | Demonstrates conditional execution. |
| `smart-pipeline.yml` | Combines all concepts into one workflow. |

---

# What I Learned

By completing Day 43, I learned how to:

- Create workflows with multiple jobs.
- Execute jobs in sequence using `needs`.
- Run jobs in parallel for faster workflows.
- Use environment variables effectively.
- Access GitHub context variables.
- Pass outputs between jobs.
- Apply conditional logic to workflows.
- Build more organized and efficient CI/CD pipelines.

---

# Key Takeaways

- Every job runs on a fresh runner.
- `needs` controls the order of job execution.
- Environment variables improve workflow reusability.
- Job outputs allow data sharing between jobs.
- Conditionals make workflows more flexible.
- Parallel jobs help reduce workflow execution time.

---

## 🚀 Conclusion

Day 43 focused on controlling workflow execution in GitHub Actions. By learning about jobs, dependencies, environment variables, outputs, and conditional execution, I gained a deeper understanding of how professional CI/CD pipelines are designed and managed. These concepts provide the foundation for creating reliable, maintainable, and scalable automation workflows.

---

## 📚 Resources

- GitHub Actions Documentation: https://docs.github.com/en/actions
- Workflow Syntax: https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions
- Contexts Reference: https://docs.github.com/en/actions/learn-github-actions/contexts
- Expressions Reference: https://docs.github.com/en/actions/learn-github-actions/expressions
