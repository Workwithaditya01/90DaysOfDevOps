
# 📅 Day 28 – Revision Day (Days 1–27)

> **90 Days of DevOps Challenge**  
> **Theme:** Revision, Self-Assessment & Knowledge Reinforcement

---

# 🎯 Objective

Today was dedicated to revising everything learned from **Day 1 to Day 27**. Instead of learning new concepts, I focused on reinforcing my understanding, identifying weak areas, and ensuring I can confidently explain and apply the topics covered so far.

---

# 📚 Topics Covered

| Days | Topic | Concepts Covered |
| :---: | ------ | ---------------- |
| 1 | DevOps & Cloud | DevOps, SDLC, Cloud Basics |
| 2–7 | Linux Fundamentals | Commands, File System, Processes, Services, Troubleshooting |
| 8 | Cloud Server Setup | Docker, Nginx, Web Deployment |
| 9–11 | Users & Permissions | Users, Groups, chmod, chown, chgrp |
| 12 | Revision | Linux Revision |
| 13 | Volume Management | LVM |
| 14–15 | Networking | DNS, IP Addressing, Ports, Subnets |
| 16–21 | Shell Scripting | Variables, Loops, Functions, Error Handling, Automation |
| 22–27 | Git & GitHub | Branching, Merge, Rebase, Stash, GitHub CLI, Profile Branding |

---

# ✅ Task 1 – Self Assessment

## Linux

| Topic | Status |
| ------ | ------ |
| File & Directory Management | ✅ Confident |
| Process Management | ✅ Confident |
| Systemd Services | ✅ Confident |
| Vim / Nano | ✅ Confident |
| CPU, Memory & Disk Troubleshooting | ✅ Confident |
| Linux File System Hierarchy | ✅ Confident |
| User & Group Management | ✅ Confident |
| File Permissions | ✅ Confident |
| File Ownership | ✅ Confident |
| LVM | 🔄 Need More Practice |
| Networking Commands | ✅ Confident |
| DNS, Subnets & Ports | 🔄 Need More Practice |

### Shell Scripting

| Topic | Status |
| ------ | ------ |
| Variables & Arguments | ✅ Confident |
| Conditionals | ✅ Confident |
| Loops | ✅ Confident |
| Functions | 🔄 Need More Practice |
| Text Processing (grep, awk, sed) | ✅ Confident |
| Error Handling | ✅ Confident |
| Cron Jobs | ✅ Confident |

### Git & GitHub

| Topic | Status |
| ------ | ------ |
| Git Basics | ✅ Confident |
| Branching | ✅ Confident |
| Push & Pull | ✅ Confident |
| Clone vs Fork | ✅ Confident |
| Merge | ✅ Confident |
| Rebase | ✅ Confident |
| Stash | ✅ Confident |
| Cherry-pick | ✅ Confident |
| Reset & Revert | ✅ Confident |
| Branching Strategies | 🔄 Need More Practice |
| GitHub CLI | ✅ Confident |

---

# 🔄 Task 2 – Topics Revisited

## 1. Logical Volume Manager (LVM)

### What I Revised

- Understood the relationship between Physical Volumes (PV), Volume Groups (VG), and Logical Volumes (LV).
- Learned how LVM allows disks to be resized without repartitioning.
- Practiced extending logical volumes.

---

## 2. Shell Functions

### What I Revised

- Creating reusable functions.
- Passing arguments using `$1`, `$2`, etc.
- Returning exit codes.
- Improving script readability.

---

## 3. Git Branching Strategies

### What I Revised

- GitFlow
- GitHub Flow
- Trunk-Based Development
- Choosing the appropriate workflow based on team size and release frequency.

---

# ⚡ Task 3 – Quick Fire Questions

## What does `chmod 755 script.sh` do?

It assigns the following permissions:

- **Owner:** Read, Write, Execute
- **Group:** Read, Execute
- **Others:** Read, Execute

---

## Difference between a Process and a Service

| Process | Service |
|---------|---------|
| A running program | A background program managed by the operating system |
| Can be started manually | Usually starts automatically |
| May terminate after execution | Typically runs continuously |

---

## How do you find which process is using port 8080?

```bash
ss -tulnp | grep 8080
````

or

```bash
netstat -tulnp | grep 8080
```

---

## What does `set -euo pipefail` do?

* `set -e` → Exit immediately if a command fails.
* `set -u` → Treat undefined variables as errors.
* `set -o pipefail` → Return failure if any command in a pipeline fails.

---

## Difference between `git reset --hard` and `git revert`

| git reset --hard               | git revert                               |
| ------------------------------ | ---------------------------------------- |
| Removes commits from history   | Creates a new commit that undoes changes |
| Rewrites history               | Preserves history                        |
| Unsafe for shared repositories | Safe for collaboration                   |

---

## Best branching strategy for a team of five developers shipping weekly

**GitHub Flow** is the most suitable because it is simple, lightweight, and supports frequent deployments through Pull Requests.

---

## What does `git stash` do?

Temporarily saves uncommitted changes so you can switch branches or pull updates without creating unnecessary commits.

---

## How do you schedule a script to run every day at 3 AM?

```cron
0 3 * * * /path/to/script.sh
```

---

## Difference between `git fetch` and `git pull`

| git fetch                      | git pull                     |
| ------------------------------ | ---------------------------- |
| Downloads latest changes       | Downloads and merges changes |
| Does not modify current branch | Updates current branch       |

---

## What is LVM?

Logical Volume Manager (LVM) is a flexible storage management system that allows administrators to resize, extend, and manage disk partitions dynamically without repartitioning the physical disk.

---

# 📂 Task 4 – Repository Checklist

* ✅ All Day 1–27 tasks committed.
* ✅ All changes pushed to GitHub.
* ✅ Git command notes updated.
* ✅ Shell scripting cheat sheet completed.
* ✅ GitHub profile cleaned and organized.

---

# 👨‍🏫 Task 5 – Teach It Back

## Explaining Git Branching

Git branching allows developers to work on new features or bug fixes without affecting the main project. Each branch acts as an independent workspace where changes can be developed safely. Once the feature is complete and tested, it can be merged back into the main branch. This enables multiple developers to collaborate simultaneously while keeping the stable version of the project unaffected.

---

# 📝 Key Takeaways

* Reinforced Linux fundamentals and troubleshooting.
* Improved confidence in Shell Scripting concepts.
* Strengthened Git and GitHub knowledge.
* Identified LVM, Networking, and Branching Strategies as areas requiring additional practice.
* Successfully revised all concepts covered during the first 27 days of the challenge.

---

# 🚀 Conclusion

Day 28 was a valuable checkpoint in my **90 Days of DevOps** journey. Revising previous topics helped strengthen my understanding, reveal areas for improvement, and prepare me for more advanced DevOps concepts in the upcoming days.

```
```

