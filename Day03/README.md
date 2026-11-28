# Day 03 - Linux Commands Practice

A quick-reference cheatsheet of essential Linux commands for process management, working with the file system, and networking and troubleshooting.

## Table of Contents

- [Process Management](#process-management)
- [File System Commands](#file-system-commands)
- [Networking and Troubleshooting](#networking-and-troubleshooting)

## Process Management

| Command | Definition |
|---------|------------|
| `ps aux` | Display all running processes. |
| `top` | Monitor system processes in real time. |
| `kill <PID>` | Terminate a process using its PID. |
| `pkill <name>` | Kill processes by name. |
| `pgrep <name>` | Find a process ID by process name. |

Example:

```bash
pgrep nginx       # find the PID of nginx
kill 1234         # terminate the process with PID 1234
pkill nginx       # or kill it by name
```

## File System Commands

| Command | Definition |
|---------|------------|
| `pwd` | Display the current working directory. |
| `ls` | List all files and directories. |
| `cd <dir>` | Change directory. |
| `touch <filename>` | Create a file. |
| `cp <src> <dest>` | Copy a file from source to destination. |
| `mv <src> <dest>` | Move or rename a file. |
| `rm -r <dir>` | Remove a directory and its contents. |
| `cat <filename>` | Display the contents of a file. |
| `df -h` | Display disk space usage in human-readable format. |
| `chmod` | Change file permissions. |
| `chown` | Change file owner. |

> **Caution:** `rm -r` deletes permanently with no recycle bin. Double-check the path before running it.

## Networking and Troubleshooting

| Command | Usage |
|---------|-------|
| `ping google.com` | Test network connectivity. |
| `ip addr` | Display network interfaces and IP addresses. |
| `curl https://example.com` | Fetch data from a URL. |
| `dig google.com` | Query DNS information. |
| `nslookup google.com` | Look up DNS records. |
| `ss -tulnp` | Show listening ports and active connections. |
| `netstat -tulnp` | Display network statistics (legacy tool). |
| `traceroute google.com` | Trace the packet route to a host. |
| `wget <url>` | Download files from the internet. |
| `hostname -I` | Display the local IP address. |

## Key Takeaways

- Use `ps`, `top`, and `pgrep` to find processes, and `kill` or `pkill` to stop them.
- Use `df -h`, `chmod`, and `chown` to inspect and manage disk space, permissions, and ownership.
- Start network troubleshooting with `ping`, then use `dig` or `nslookup` for DNS and `ss` for open ports.
