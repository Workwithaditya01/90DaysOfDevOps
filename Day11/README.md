# Day 11 – Linux File & Directory Ownership

## 📌 Overview

On **Day 11** of the **90 Days of DevOps Challenge**, I learned how Linux manages **file and directory ownership**. Understanding ownership is essential for controlling access to files and securing Linux systems.

This day focused on identifying file owners and groups, changing ownership using `chown`, modifying groups with `chgrp`, and applying ownership changes recursively.

---

## 🎯 Objectives

- Understand Linux file ownership
- Learn the difference between **Owner** and **Group**
- Change file ownership using `chown`
- Change file groups using `chgrp`
- Change both owner and group together
- Apply ownership recursively using the `-R` option

---

# Task 1: Understanding File Ownership

### List files with detailed information

```bash
ls -l
```

Example Output:

```text
-rw-r--r-- 1 aditya aditya 256 Aug 5 10:30 notes.txt
```

### Explanation

| Field | Description |
|--------|-------------|
| `-rw-r--r--` | File permissions |
| `1` | Number of links |
| `aditya` | Owner |
| `aditya` | Group |
| `256` | File size |
| `Aug 5 10:30` | Last modified date |
| `notes.txt` | File name |

### Owner vs Group

**Owner**
- User who owns the file
- Has primary control over the file

**Group**
- Collection of users
- Permissions can be shared among multiple users

---

# Task 2: Basic `chown` Operations

### Create a file

```bash
touch devops-file.txt
```

### Check ownership

```bash
ls -l devops-file.txt
```

### Create users (if they don't exist)

```bash
sudo useradd tokyo
sudo useradd berlin
```

### Change owner

```bash
sudo chown tokyo devops-file.txt
```

Verify

```bash
ls -l devops-file.txt
```

Change owner again

```bash
sudo chown berlin devops-file.txt
```

Verify

```bash
ls -l devops-file.txt
```

---

# Task 3: Basic `chgrp` Operations

### Create file

```bash
touch team-notes.txt
```

### Create group

```bash
sudo groupadd heist-team
```

### Change group

```bash
sudo chgrp heist-team team-notes.txt
```

Verify

```bash
ls -l team-notes.txt
```

---

# Task 4: Change Owner and Group Together

### Create file

```bash
touch project-config.yaml
```

Change owner and group

```bash
sudo chown professor:heist-team project-config.yaml
```

### Create directory

```bash
mkdir app-logs
```

Assign owner and group

```bash
sudo chown berlin:heist-team app-logs
```

Verify

```bash
ls -ld app-logs
```

---

# Task 5: Recursive Ownership

### Create directory structure

```bash
mkdir -p heist-project/vault
mkdir -p heist-project/plans

touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf
```

### Create group

```bash
sudo groupadd planners
```

### Change ownership recursively

```bash
sudo chown -R professor:planners heist-project
```

Verify

```bash
ls -lR heist-project
```

---

# Task 6: Practice Challenge

### Create users

```bash
sudo useradd tokyo
sudo useradd berlin
sudo useradd nairobi
```

### Create groups

```bash
sudo groupadd vault-team
sudo groupadd tech-team
```

### Create project directory

```bash
mkdir bank-heist
```

### Create files

```bash
touch bank-heist/access-codes.txt
touch bank-heist/blueprints.pdf
touch bank-heist/escape-plan.txt
```

### Assign ownership

```bash
sudo chown tokyo:vault-team bank-heist/access-codes.txt

sudo chown berlin:tech-team bank-heist/blueprints.pdf

sudo chown nairobi:vault-team bank-heist/escape-plan.txt
```

Verify

```bash
ls -l bank-heist
```

---

# 📚 Commands Learned

| Command | Purpose |
|----------|---------|
| `ls -l` | Display detailed file information |
| `touch` | Create a file |
| `mkdir` | Create a directory |
| `mkdir -p` | Create nested directories |
| `useradd` | Create a new user |
| `groupadd` | Create a new group |
| `chown` | Change file owner |
| `chgrp` | Change file group |
| `chown owner:group` | Change owner and group together |
| `chown -R` | Apply ownership recursively |
| `ls -lR` | Display recursive directory listing |

---

# 💡 Key Takeaways

- Every Linux file has an **Owner** and a **Group**.
- `chown` changes file ownership.
- `chgrp` changes only the group ownership.
- `chown owner:group` updates both owner and group in a single command.
- The `-R` option recursively changes ownership for directories and all their contents.
- Always verify ownership changes using `ls -l`.

---

## 🏁 Conclusion

Day 11 strengthened my understanding of Linux file ownership and access management. These concepts are fundamental for Linux system administration, DevOps, and server security. Mastering ownership management helps ensure proper access control and secure collaboration in multi-user environments.

---

### 🔖 Challenge

**90 Days of DevOps Challenge**

**Day 11 Completed ✅**
