# 🚀 Day 44 – Secrets, Artifacts & Running Real Tests in GitHub Actions

Welcome to **Day 44** of my **#90DaysOfDevOps** journey!

Today, I explored some of the most important features of GitHub Actions that make CI pipelines secure, reliable, and efficient. I learned how to manage sensitive information using GitHub Secrets, share files between jobs with Artifacts, run real tests automatically, and speed up workflows using dependency caching.

---

# 📚 Topics Covered

- 🔐 GitHub Secrets
- 🌍 Environment Variables
- 📦 Uploading Artifacts
- 🔄 Downloading Artifacts Between Jobs
- ✅ Running Real Tests in CI
- ⚡ Dependency Caching

---

# ✅ Tasks Completed

## 🔐 Task 1 – GitHub Secrets

### Objective

Learn how to securely store and use sensitive information inside GitHub Actions.

### What I Did

- Created a repository secret named `MY_SECRET_MESSAGE`.
- Verified that the secret was available during workflow execution.
- Observed that GitHub automatically masks secret values in workflow logs.

### What I Learned

- Secrets are used to securely store sensitive information such as passwords, API keys, and access tokens.
- GitHub automatically replaces secret values with `***` in workflow logs.
- Sensitive information should never be hardcoded or printed in CI pipelines.

---

## 🌍 Task 2 – Environment Variables

### Objective

Use GitHub Secrets as environment variables.

### What I Did

- Added Docker credentials as repository secrets.
- Passed the secrets into workflow steps using the `env` keyword.
- Used the environment variables safely without exposing their values.

### What I Learned

Using environment variables keeps workflows secure and makes it easier to reuse secrets across different workflow steps.

---

## 📦 Task 3 – Upload Artifacts

### Objective

Store generated files after a workflow completes.

### What I Did

- Generated a sample report during the workflow.
- Uploaded the report as a workflow artifact.

### What I Learned

Artifacts allow important files such as reports, logs, or build outputs to be saved even after the workflow finishes.

---

## 🔄 Task 4 – Download Artifacts Between Jobs

### Objective

Share files between multiple jobs in the same workflow.

### What I Did

- Generated a file in one job.
- Uploaded it as an artifact.
- Downloaded it in another job.
- Verified its contents.

### Real-World Use Cases

- Sharing build outputs between jobs
- Passing test reports
- Deployment packages
- Log files for debugging

---

## ✅ Task 5 – Running Real Tests in CI

### Objective

Run actual scripts automatically inside GitHub Actions.

### What I Did

- Executed a Shell script.
- Executed a Python script.
- Verified that the workflow passed successfully.
OBOBOB- Intentionally introduced an error to make the workflow fail.
OBOBOB- Fixed the error and confirmed the workflow passed again.

### What I Learned

OBOBOBRunning automated tests ensures that issues are detected early before code reaches production.

OBOBOB---

OBOBOB## ⚡ Task 6 – Dependency Caching

### Objective
OBOBOB
Reduce workflow execution time by caching dependencies.

### What I Did

- Configured dependency caching using GitHub Actions.
- Compared the first workflow run with subsequent runs.

### What I Learned

- The first run downloads all dependencies.
- Later runs restore cached dependencies, making workflows significantly faster.
- Caching improves CI performance and reduces unnecessary downloads.

---

# 🎯 Key Takeaways
OBOBOB
OBOBOB- Learned how GitHub securely manages sensitive information using Secrets.
- Understood how environment variables help keep workflows secure.
OBOBOB- Learned how Artifacts can be used to share files between jobs.
- Automated Shell and Python tests using GitHub Actions.
OBOBOBOBOBOB- Observed both successful and failed workflow executions.
- Improved workflow performance by implementing dependency caching.
OBOBOB
---

# 🛠️ Technologies Used

- GitHub Actions
- YAML
- Bash
- Python
- Git
- Ubuntu

---

# 📖 Conclusion

Day 44 helped me understand how real CI pipelines work beyond simply executing commands. By combining secrets management, artifacts, automated testing, and caching, I built workflows that are more secure, efficient, and closer to production-ready DevOps practices.

I'm excited to continue learning and applying these concepts throughout my **#90DaysOfDevOps** journey.

---

### ⭐ Thank you for visiting this repository! If you found it helpful, consider giving it a star.
