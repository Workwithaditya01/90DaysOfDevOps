# Day 05 – Linux Troubleshooting Drill: CPU, Memory, and Logs 🚑

Part of the [#90DaysOfDevOps](https://github.com/Workwithaditya01/90DaysOfDevOps) challenge.

## 🎯 Goal

Turn yesterday's practice into a repeatable troubleshooting routine by running a focused drill and writing it up as a **mini runbook**.

> **What's a runbook?** A short, repeatable checklist followed during an incident: the exact commands run, what was observed, and the next actions if the issue persists.

## 📋 Task

Pick a running process/service and:
- Capture a quick health snapshot (CPU, memory, disk, network)
- Trace logs for that service
- Write a mini runbook describing what you did and what you'd do next if things got worse

### Requirements
- Record output for **at least 8 commands** across:
  - Environment basics (`uname -a`, `cat /etc/os-release`)
  - Filesystem sanity (`mkdir`, `cp`, `ls -l`)
  - CPU / Memory (`top`, `ps -o pid,pcpu,pmem`, `free -h`)
  - Disk / IO (`df -h`, `du -sh`)
  - Network (`ss -tulpn`, `curl -I` / `ping`)
  - Logs (`journalctl -u <service> -n 50`, `tail -n 50 <log>`)
- Stick to **one target service/process** for the whole drill
- Add a 1–2 line observation note per command
- End with an **"If this worsens"** section listing 3 next steps

## 📁 Files in this folder

| File | Description |
|------|--------------|
| [`learning-path.md`](./learning-path.md) | Full task description, guidelines, and submission steps |
| [`linux-troubleshooting-runbook.md`](./linux-troubleshooting-runbook.md) | Completed troubleshooting runbook |

## 🩺 Runbook Summary

| Category | Commands Run |
|----------|---------------|
| Environment basics | `uname -a`, `cat /etc/os-release` |
| Filesystem sanity | `mkdir /tmp/runbook-demo`, `cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo` |
| CPU / Memory | `systemctl status ssh` (and related resource checks) |

Environment observed: **Ubuntu 26.04 LTS**, kernel `7.0.0-1004-aws`.

> Full snapshots, log traces, and the "if this worsens" next steps are documented in [`linux-troubleshooting-runbook.md`](./linux-troubleshooting-runbook.md).

## 💡 Why It Matters

Incidents rarely come with perfect clues. A fast, repeatable checklist saves minutes when services misbehave — building the habit of capturing evidence before acting, reading resource signals with confidence, and thinking "logs first" before restarting or escalating.

## 📢 Learn in Public

Share your Day 05 progress on LinkedIn:
- 2–3 lines on the checks you ran and one insight
- The service you inspected and one "next step" from your runbook
- Optional: a screenshot of your runbook

Use the hashtags: `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

---
Happy Learning 🚀
