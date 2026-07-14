# Day 07 – Linux File System Hierarchy & Basic Troubleshooting

> **90 Days of DevOps Challenge**

## 📖 Overview

On Day 07 of my **#90DaysOfDevOps** challenge, I explored the **Linux File System Hierarchy (FHS)** and practiced basic troubleshooting techniques using essential Linux commands.

Understanding the Linux filesystem is one of the most important skills for a DevOps Engineer. It helps in locating configuration files, logs, executables, user data, and diagnosing issues efficiently on Linux servers.

---

## 🎯 Objectives

- Understand the Linux File System Hierarchy (FHS)
- Learn the purpose of important Linux directories
- Practice filesystem navigation
- Explore commonly used Linux commands
- Perform basic troubleshooting
- Understand where configuration files and logs are stored

---

# 🗂️ Linux File System Hierarchy

```text
/
├── bin
├── boot
├── dev
├── etc
├── home
├── lib
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── srv
├── sys
├── tmp
├── usr
└── var
```

---

# 📂 Important Linux Directories

| Directory | Description |
|-----------|-------------|
| `/` | Root directory. Every file and directory starts from here. |
| `/home` | Home directories of normal users. |
| `/root` | Home directory of the root (administrator) user. |
| `/etc` | Stores system configuration files. |
| `/var` | Stores logs, caches, spool files, and variable data. |
| `/usr` | Contains installed applications, libraries, and documentation. |
| `/bin` | Essential user commands such as `ls`, `cp`, `mv`, and `cat`. |
| `/sbin` | System administration commands used by the root user. |
| `/tmp` | Temporary files created by users and applications. |
| `/opt` | Optional or third-party software installations. |
| `/dev` | Device files representing hardware devices. |
| `/proc` | Virtual filesystem containing process and kernel information. |

---

# 💻 Commands Practiced

## Check Current Working Directory

```bash
pwd
```

---

## List Files and Directories

```bash
ls
```

Long listing:

```bash
ls -l
```

Show hidden files:

```bash
ls -la
```

---

## Change Directory

```bash
cd /etc
```

```bash
cd /home
```

Go back one directory:

```bash
cd ..
```

---

## Display Directory Tree

```bash
tree
```

---

## Search Files

```bash
find /etc -name "*.conf"
```

---

## Check Disk Usage

```bash
du -sh /var
```

---

## Check Available Disk Space

```bash
df -h
```

---

## View File Contents

```bash
cat filename.txt
```

---

## Read Large Files

```bash
less /var/log/syslog
```

---

# 🔍 Basic Troubleshooting

One of the primary responsibilities of a DevOps Engineer is troubleshooting Linux systems.

During this practice, I explored where important system files are stored.

| File Type | Location |
|-----------|----------|
| Configuration Files | `/etc` |
| System Logs | `/var/log` |
| User Files | `/home` |
| Temporary Files | `/tmp` |
| Running Process Information | `/proc` |
| Installed Applications | `/usr` |

These directories are frequently used while diagnosing application or server issues.

---

# 📚 Learning Outcomes

After completing Day 07, I learned:

- Linux File System Hierarchy (FHS)
- Purpose of major Linux directories
- Linux filesystem navigation
- Locating configuration files
- Viewing system logs
- Basic Linux troubleshooting
- Essential Linux commands used by DevOps Engineers

---

# 📁 Project Structure

```text
Day07/
│
├── README.md
└── screenshots/
    ├── filesystem-tree.png
    ├── pwd-command.png
    ├── ls-command.png
    └── troubleshooting.png
```

---

# 📋 Commands Summary

```bash
pwd
ls
ls -l
ls -la
cd
tree
find
du -sh
df -h
cat
less
```

---

# 💡 Key Takeaways

- Linux follows a standardized File System Hierarchy (FHS).
- Every directory serves a specific purpose.
- Configuration files are stored in `/etc`.
- Logs are stored in `/var/log`.
- User data resides in `/home`.
- Knowing the filesystem hierarchy makes troubleshooting faster and more efficient.
- Strong Linux fundamentals are essential for DevOps, Cloud, and System Administration roles.

---

# ✅ Conclusion

Day 07 strengthened my understanding of Linux internals by introducing the File System Hierarchy and basic troubleshooting techniques. These foundational concepts are essential for managing Linux servers, identifying issues, and performing day-to-day DevOps tasks in production environments.

---

## 🚀 Next Step

In **Day 08**, I will deploy a real web server on an AWS EC2 instance, configure networking and security groups, and learn practical cloud server management.

---

**#90DaysOfDevOps**
