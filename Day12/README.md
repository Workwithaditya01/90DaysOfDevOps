# Day 12 – Revision & Fundamentals Checkpoint

## 📖 Overview

Day 12 was dedicated to revising and reinforcing the Linux and DevOps fundamentals covered during Days 01–11. Instead of introducing new concepts, the focus was on reviewing previous topics, practicing essential commands, and identifying areas that need further improvement.

Regular revision helps strengthen understanding, improve command recall, and build confidence for real-world system administration and DevOps tasks.

---

# 🎯 Objectives

- Review Linux concepts learned in Days 01–11
- Practice commonly used Linux commands
- Revisit process and service management
- Refresh file management and permissions
- Verify user and ownership management
- Perform a self-assessment
- Update the learning roadmap

---

# 📝 Topics Reviewed

## Mindset & Learning Plan

- Reviewed the original learning goals.
- Evaluated progress made over the first 11 days.
- Updated focus areas for the coming days.

---

## Processes & Services

Reviewed commands used to inspect system processes and monitor Linux services.

### Commands Practiced

```bash
ps aux
```

```bash
systemctl status ssh
```

```bash
journalctl -u ssh
```

### Key Learning

- View active system processes.
- Check service status.
- Read service logs for troubleshooting.

---

# 📂 File Management Practice

Practiced common file operations and permission management.

### Commands Practiced

```bash
echo "Revision practice" >> notes.txt
```

```bash
chmod 644 notes.txt
```

```bash
cp notes.txt backup-notes.txt
```

### Key Learning

- Append content to files.
- Modify file permissions.
- Create backup copies.

---

# 👥 User & Ownership Review

Recreated a simple user management scenario.

### Commands Practiced

```bash
sudo useradd devuser
```

```bash
id devuser
```

```bash
ls -l
```

### Key Learning

- Create users.
- Verify user information.
- Check file ownership.

---

# 🚨 Incident Response Cheat Sheet

These are some of the first commands to use while troubleshooting a Linux system.

```bash
pwd
```

```bash
ls -la
```

```bash
ps aux
```

```bash
systemctl status <service>
```

```bash
journalctl -xe
```

---

# ✅ Mini Self-Assessment

## 1. Which commands save the most time?

- `ls -la` – Quickly displays files, permissions, and ownership.
- `systemctl status` – Instantly checks the health of a service.
- `journalctl` – Helps diagnose issues through system and service logs.

---

## 2. How do you check whether a service is healthy?

```bash
systemctl status <service>
```

```bash
ps aux | grep <service>
```

```bash
journalctl -u <service>
```

---

## 3. How do you safely change ownership and permissions?

```bash
sudo chown ubuntu:ubuntu app.log
```

```bash
chmod 644 app.log
```

These commands ensure the correct owner has access while maintaining secure file permissions.

---

## 4. Focus Areas for the Next Three Days

- Linux troubleshooting
- Service monitoring
- Log analysis
- User and permission management
- More hands-on Linux practice

---

# 💡 Key Takeaways

- Revision improves long-term retention.
- Linux fundamentals are the backbone of DevOps.
- Understanding permissions and ownership is essential.
- Service monitoring and log analysis are valuable troubleshooting skills.
- Consistent daily practice builds confidence and practical experience.

---

# 📚 Skills Reinforced

- Linux Commands
- Process Management
- Service Management
- File Management
- File Permissions
- Ownership Management
- User Administration
- Linux Troubleshooting
- System Logs

---

# 🎯 Conclusion

Day 12 served as a checkpoint to consolidate everything learned so far. Revisiting previous concepts strengthened my understanding and highlighted areas for improvement before progressing further in the 90 Days of DevOps journey.

Consistent revision is just as important as learning new concepts, and this session reinforced the importance of building a solid Linux foundation for a successful DevOps career.

---

## 🙌 Connect With Me

If you're also learning DevOps or Linux, feel free to connect and follow my journey.

- **LinkedIn:** www.linkedin.com/in/aditya-sondekar
- **GitHub:** https://github.com/Workwithaditya01

Happy Learning! 🚀
