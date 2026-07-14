# 🔐 Mastering Linux File Permissions & Access Control | DevOps Fundamentals

## 📅 Day 10 – File Permissions & File Operations Challenge Completed

## 📖 Overview

On Day 10 of my **#90DaysOfDevOps** journey, I focused on Linux file operations and permission management. This challenge helped me understand how Linux manages file access through the **read (r)**, **write (w)**, and **execute (x)** permission model. I also practiced creating, reading, and managing files while modifying permissions using the `chmod` command.

---

## 🎯 Objectives

- Create and manage files using Linux commands
- Read file contents using different utilities
- Understand the Linux permission model (`rwx`)
- Modify file and directory permissions using `chmod`
- Test file access and script execution permissions

---

## 🛠️ Commands Practiced

### File Operations

```bash
touch devops.txt
echo "Linux permissions are important for system security." > notes.txt
vim script.sh
cat notes.txt
head -n 5 /etc/passwd
tail -n 5 /etc/passwd
ls -l
mkdir project
````

### Permission Management

```bash
chmod +x script.sh
./script.sh

chmod a-w devops.txt

chmod 640 notes.txt

chmod 755 project
```

---

## ✅ Tasks Completed

* Created files using `touch`, `echo`, and `vim`
* Read file contents using `cat`, `head`, and `tail`
* Verified file permissions using `ls -l`
* Learned the Linux permission structure (**Owner, Group, Others**)
* Modified file and directory permissions using `chmod`
* Made a shell script executable
* Created a directory with **755** permissions
* Tested permission-related errors and access control

---

## 📚 Key Learnings

* Understood the Linux permission model (`rwx`)
* Learned how `chmod` changes file and directory permissions
* Practiced executing shell scripts with proper permissions
* Explored permission values such as **640** and **755**
* Strengthened Linux fundamentals required for DevOps

---

## 💡 Skills Gained

* Linux
* File Operations
* File Permissions
* Access Control
* `chmod`
* Shell Scripting
* Linux System Administration
* DevOps Fundamentals

---

## 🚀 Conclusion

Day 10 strengthened my understanding of Linux file operations and permission management. These concepts are essential for system administration, automation, and building a strong foundation in DevOps.

```
```
