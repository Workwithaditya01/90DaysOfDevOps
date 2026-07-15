# Day 38 – YAML Basics

## 📌 Objective

Before writing CI/CD pipelines with tools like GitHub Actions, Jenkins, GitLab CI, or Azure DevOps, it's important to understand **YAML (YAML Ain't Markup Language)**.

In this challenge, I learned the basic syntax of YAML, created YAML files from scratch, understood indentation rules, and validated them using a YAML validator.

---

# 📚 What is YAML?

YAML is a human-readable data serialization language commonly used for:

- CI/CD Pipelines
- Kubernetes Manifests
- Docker Compose
- Ansible Playbooks
- Configuration Files

Unlike JSON or XML, YAML focuses on readability.

---

# ✅ Task 1 – Key-Value Pairs

Created **person.yaml**

```yaml
name: Aditya Sondekar
role: DevOps Learner
experience_years: 0
learning: true
```

### Commands

```bash
cat person.yaml
```

---

# ✅ Task 2 – Lists

Updated **person.yaml**

```yaml
name: Aditya Sondekar
role: DevOps Learner
experience_years: 0
learning: true

tools:
  - Linux
  - Git
  - Docker
  - GitHub
  - AWS

hobbies: [Coding, Reading, Gaming]
```

### Two ways to create lists

### Block Style

```yaml
tools:
  - Docker
  - Git
  - Linux
```

### Inline Style

```yaml
tools: [Docker, Git, Linux]
```

---

# ✅ Task 3 – Nested Objects

Created **server.yaml**

```yaml
server:
  name: web-server
  ip: 192.168.1.10
  port: 80

database:
  host: localhost
  name: appdb

  credentials:
    user: admin
    password: secret123
```

---

# ✅ Task 4 – Multi-line Strings

Added startup scripts using both YAML block styles.

### Literal Style (`|`)

Preserves line breaks exactly.

```yaml
startup_script_literal: |
  echo "Starting Server..."
  sudo systemctl start nginx
  echo "Server Started"
```

Output:

```
echo "Starting Server..."
sudo systemctl start nginx
echo "Server Started"
```

---

### Folded Style (`>`)

Converts multiple lines into a single line.

```yaml
startup_script_folded: >
  echo "Starting Server..."
  sudo systemctl start nginx
  echo "Server Started"
```

Output:

```
echo "Starting Server..." sudo systemctl start nginx echo "Server Started"
```

---

# ✅ Task 5 – Validate YAML

Installed **yamllint**

Ubuntu

```bash
sudo apt update
sudo apt install yamllint
```

Validate files

```bash
yamllint person.yaml
yamllint server.yaml
```

### Example Error

When indentation is incorrect:

```yaml
server:
	name: web-server
```

Output

```
syntax error: found character '\t' that cannot start any token
```

After replacing tabs with spaces, validation succeeds.

---

# ✅ Task 6 – Spot the Difference

Correct YAML

```yaml
name: devops

tools:
  - docker
  - kubernetes
```

Broken YAML

```yaml
name: devops

tools:
- docker
  - kubernetes
```

### What's wrong?

The list indentation is inconsistent.

`docker` is not properly indented under `tools`, making the structure confusing and causing validation issues depending on the parser.

Correct indentation should be:

```yaml
tools:
  - docker
  - kubernetes
```

---

# 📖 Key Learnings

- YAML relies entirely on **spaces** for indentation; tabs are not allowed.
- YAML supports **key-value pairs, lists, nested objects, and multi-line strings**.
- Always validate YAML before using it in CI/CD pipelines or Kubernetes manifests.

---

# 📂 Project Structure

```
2026/
└── day-38/
    ├── person.yaml
    ├── server.yaml
    └── day-38-yaml.md
```

---

# 🚀 Git Commands

```bash
git add .
git commit -m "Day 38 - Learned YAML Basics"
git push origin main
```

---

# 🎯 Outcome

Successfully learned the fundamentals of YAML including:

- Key-value pairs
- Lists
- Nested objects
- Multi-line strings
- YAML validation
- Indentation rules
- Common syntax mistakes

This knowledge forms the foundation for writing configuration files in Docker Compose, Kubernetes, GitHub Actions, Jenkins, GitLab CI/CD, and many other DevOps tools.

---

## 🔗 Connect With Me

I'm documenting my **#90DaysOfDevOps** journey by sharing my daily progress on GitHub and LinkedIn.

Let's learn and grow together! 🚀

---

**#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #YAML #Docker #Kubernetes #GitHubActions #DevOps**
