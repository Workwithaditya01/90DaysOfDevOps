# Day 04 – Linux Practice: Processes and Services

## 📖 Overview

Day 04 focused on gaining hands-on experience with Linux processes, system services, and log management. The objective was to understand how Linux manages running applications and services while practicing basic troubleshooting techniques commonly used by DevOps Engineers.

---

## 🎯 Objectives

- Practice Linux process management
- Inspect and manage system services
- Analyze system logs
- Perform basic troubleshooting using Linux commands

---

## ✅ Tasks Completed

- [x] Checked running processes
- [x] Inspected a systemd service
- [x] Viewed service logs
- [x] Practiced basic troubleshooting
- [x] Documented command usage

---

# 🖥️ Process Checks

### Display all running processes

```bash
ps -ef
```

### Monitor system processes in real time

```bash
top
```

### Search for a specific process

```bash
pgrep ssh
```

---

# ⚙️ Service Checks

### Check the status of a service

```bash
systemctl status ssh
```

### List all active services

```bash
systemctl list-units --type=service
```

---

# 📄 Log Checks

### View logs of a specific service

```bash
journalctl -u ssh
```

### View the last 50 lines of system logs

```bash
tail -n 50 /var/log/syslog
```

> **Note:** Depending on your Linux distribution, the log file may be `/var/log/messages` instead of `/var/log/syslog`.

---

# 🔍 Mini Troubleshooting

### Scenario

Verify whether the SSH service is running correctly.

### Commands Used

```bash
systemctl status ssh
journalctl -u ssh
```

### Troubleshooting Steps

1. Checked the service status.
2. Verified whether the service was active.
3. Reviewed recent logs.
4. Confirmed there were no errors.

---

# 📚 Commands Practiced

| Category | Commands |
|----------|----------|
| Process Management | `ps`, `top`, `pgrep` |
| Service Management | `systemctl status`, `systemctl list-units` |
| Log Management | `journalctl`, `tail` |

---

# 💡 Key Learnings

- Understood how Linux manages processes.
- Learned the difference between a process and a service.
- Practiced monitoring processes using `ps`, `top`, and `pgrep`.
- Learned how to inspect services using `systemctl`.
- Explored Linux logs using `journalctl`.
- Gained confidence in basic Linux troubleshooting.

---

# 🛠️ Skills Practiced

- Linux
- Process Management
- systemd
- Service Management
- Log Analysis
- Linux Troubleshooting
- DevOps Fundamentals

---

# 🚀 Outcome

Day 04 strengthened my understanding of Linux internals through practical exercises. Process monitoring, service management, and log analysis are essential DevOps skills that form the foundation for managing production Linux servers.

---

## 📂 Repository Structure

```
Day04/
├── README.md
└── linux-practice.md
```

---

## 🔗 Connect With Me

- **LinkedIn:** *(Add your LinkedIn profile link)*
- **GitHub:** *(Add your GitHub profile link)*

---

⭐ If you found this repository helpful, consider giving it a **Star** and follow my **#90DaysOfDevOps** journey!
