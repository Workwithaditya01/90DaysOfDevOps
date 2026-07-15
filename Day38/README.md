# Day 38 – YAML Basics

## 📖 Overview

Today I learned the fundamentals of **YAML (YAML Ain't Markup Language)**, the configuration language widely used in modern DevOps tools such as **Docker Compose**, **Kubernetes**, **GitHub Actions**, **Jenkins**, and **Ansible**.

The goal of this challenge was to understand YAML syntax, create YAML configuration files, work with nested structures and lists, and validate YAML files.

---

## 🎯 Objectives

- Learn YAML syntax and formatting rules
- Create YAML files manually
- Understand key-value pairs
- Work with lists and nested objects
- Use multi-line strings
- Validate YAML files
- Identify and fix indentation errors

---

## 📂 Project Structure

```
day-38/
├── README.md
├── person.yaml
└── server.yaml
```

---

# 📝 Task 1 – Key-Value Pairs

Created a simple YAML file describing myself.

**person.yaml**

```yaml
name: Aditya Sondekar
role: DevOps Learner
experience_years: 0
learning: true
```

**Concept Learned**

- YAML stores data using `key: value`
- Booleans are written as `true` or `false`
- Numbers don't require quotes

---

# 📝 Task 2 – Lists

Added block-style and inline lists.

```yaml
tools:
  - Linux
  - Git
  - Docker
  - GitHub
  - AWS

hobbies: [Coding, Reading, Gaming]
```

### Types of Lists

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

# 📝 Task 3 – Nested Objects

Created a structured server configuration.

**server.yaml**

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

**Concept Learned**

Nested objects are created using indentation.

---

# 📝 Task 4 – Multi-line Strings

Used both YAML multi-line string formats.

### Literal Block (`|`)

```yaml
startup_script_literal: |
  echo "Starting Server..."
  sudo systemctl start nginx
  echo "Server Started"
```

Preserves line breaks exactly.

---

### Folded Block (`>`)

```yaml
startup_script_folded: >
  echo "Starting Server..."
  sudo systemctl start nginx
  echo "Server Started"
```

Converts multiple lines into a single line.

---

# 📝 Task 5 – YAML Validation

Validated YAML files using **yamllint**.

### Linux

```bash
sudo apt update
sudo apt install yamllint
```

### Windows (Python)

```bash
pip install yamllint
```

Validate files:

```bash
yamllint person.yaml
yamllint server.yaml
```

---

# 📝 Task 6 – Indentation Practice

Correct YAML

```yaml
name: devops

tools:
  - docker
  - kubernetes
```

Incorrect YAML

```yaml
name: devops

tools:
- docker
  - kubernetes
```

**Issue**

The list indentation is inconsistent.

Correct indentation should use **two spaces** before each list item.

---

# 💡 Key Learnings

- YAML is whitespace-sensitive and uses **spaces instead of tabs**.
- Lists can be written in **block** or **inline** format.
- Nested objects are created using proper indentation.
- Multi-line strings can preserve (`|`) or fold (`>`) line breaks.
- YAML validation helps detect syntax and indentation errors before deployment.

---

# 📚 Common YAML Rules

- Use spaces for indentation (2 spaces is the standard)
- Never use tabs
- Strings usually don't require quotes
- `true` and `false` are Boolean values
- Indentation defines the structure of the file

---

# 🚀 DevOps Use Cases

YAML is commonly used in:

- Docker Compose
- Kubernetes
- GitHub Actions
- Jenkins Pipelines
- Ansible Playbooks
- Azure DevOps Pipelines
- CI/CD Configuration Files

---

# 🛠️ Commands Used

```bash
cat person.yaml
cat server.yaml

yamllint person.yaml
yamllint server.yaml
```

---

# ✅ Outcome

Successfully learned the basics of YAML, including:

- Key-value pairs
- Lists
- Nested objects
- Multi-line strings
- YAML validation
- Indentation best practices

These concepts provide the foundation for writing configuration files used across modern DevOps tools and CI/CD pipelines.

---

## 📌 Connect With Me

I'm documenting my **#90DaysOfDevOps** journey by sharing daily progress on GitHub and LinkedIn.

⭐ If you found this repository helpful, feel free to star it and follow my journey!

---

**#90DaysOfDevOps #DevOps #YAML #Docker #Kubernetes #GitHubActions #TrainWithShubham**
