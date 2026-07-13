# Day 03 – Linux Commands Practice 🐧

Part of the [#90DaysOfDevOps](https://github.com/Workwithaditya01/90DaysOfDevOps) challenge.

## 🎯 Goal

Build confidence with core Linux commands by creating a personal cheat sheet — the kind of command toolkit you'll keep coming back to for years of troubleshooting.

## 📋 Task

Create a cheat sheet covering commands in three areas:

- **Process management** – inspecting and controlling running processes
- **File system** – navigating, creating, and managing files/directories
- **Networking & troubleshooting** – diagnosing connectivity issues

### Requirements
- At least **20 commands**, each with a one-line usage note
- At least **3 networking commands** (e.g. `ping`, `ip addr`, `dig`, `curl`)
- Commands grouped by category
- Concise and easy to scan under pressure

## 📁 Files in this folder

| File | Description |
|------|--------------|
| [`learning-path.md`](./learning-path.md) | Full task description, guidelines, and submission steps |
| [`linux-commands-cheatsheet.md`](./linux-commands-cheatsheet.md) | Completed cheat sheet of Linux commands |

## 🗂️ Cheat Sheet Preview

### Process Management
| Command | Description |
|---------|-------------|
| `ps aux` | Display all running processes |
| `top` | Monitor system processes in real time |
| `kill <PID>` | Terminate a process using its PID |
| `pkill <name>` | Kill processes by name |
| `pgrep <name>` | Find a process ID by process name |

### File System
| Command | Description |
|---------|-------------|
| `pwd` | Display the current working directory |
| `ls` | List directory contents |
| `cd <dir>` | Change directory |
| `touch <filename>` | Create a file |
| `cp <src> <dest>` | Copy a file |
| `mv <src> <dest>` | Move or rename a file |
| `rm -r <dir>` | Remove a directory |
| `cat <filename>` | Display file contents |
| `df -h` | Show disk space usage |
| `chmod` | Change file permissions |
| `chown` | Change file ownership |

### Networking & Troubleshooting
| Command | Description |
|---------|-------------|
| `ping google.com` | Test network connectivity |
| `ip addr` | Display network interfaces and IP addresses |
| `curl https://example.com` | Fetch data from a URL |
| `dig google.com` | Query DNS information |
| `nslookup google.com` | Look up DNS records |
| `ss -tulnp` | Show listening ports and active connections |
| `netstat -tulnp` | Display network statistics (legacy tool) |
| `traceroute google.com` | Trace the packet route to a host |
| `wget <url>` | Download files from the internet |
| `hostname -I` | Display the local IP address |

> See [`linux-commands-cheatsheet.md`](./linux-commands-cheatsheet.md) for the complete, up-to-date version.

## 💡 Why It Matters

Production issues get solved at the command line. The faster you can inspect logs and diagnose network problems, the faster you can restore service, reduce downtime, and build trust as an operator.

## 📢 Learn in Public

Share your Day 03 progress on LinkedIn:
- 2–3 lines on your favorite Linux commands
- One log command and one networking command
- Optional: a screenshot of your cheat sheet

Use the hashtags: `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

---
Happy Learning 🚀
