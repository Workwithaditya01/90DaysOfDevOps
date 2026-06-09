# Day 12 - Revision & Fundamental Checkpoints

## Objective 

```text
Today's Goal isn't about learning new tools or commands . it's about revising previous topics and practicing it .
```

---

## Day 01 Plan review

### Original Goal 

- Build a strong foundation in Linux, Git, Networking, and Cloud fundamentals.
- Create and deploy real-world DevOps projects using Docker, Kubernetes, and AWS.
- Become confident enough to apply for DevOps and Cloud-related fresher roles and internships.

### Progress Review

- Successfully completed 01-11 Days.
- Gained Confidence in linux commands, file management, permissions, users, groups, and managing serivces.
- Getting control on mind, improved focus, and knowledge

### Adjustments

- Spend little time on practicing vocabulary.
- Create Project and hand-on practices.
- Continue Focusing on linux Commands before moving to advance devops practices.


---

## Progress & Service Review

### Command Practicing 

```bash
ps aux
```

#### Observation

```text
Display all the process and it resource usage.
```

```bash
systemctl status ssh
```

#### Observation

```text
This Command is used for Verfying Whether the ssh is Active or not.
```

```bash
journalctl -u ssh
```

#### Observation

```text
This command is used to review Service logs and Recent SSH- related events.
```

---

## File Operations Practice

### Command 1

```bash
echo "Revision practice" >> notes.txt
```

### Result:

```text
Appended text successfully to an existing file.
```
### Command 2

```bash
chmod 644 notes.txt
```

### Result:

```text
Updated file permissions to allow read access for others.
```

### Command 3

```bash
cp notes.txt backup-notes.txt
```

### Result:

```text
Created a backup copy of the file.
```
---

## Incident Response Cheat Sheet

## Top 5 Commands I Would Use First

### 1.Command:

```bash
pwd
```

### Usage

```text
Verify current working directory.
```

### 2.Command

```bash
ls -la
```

### Usage

```text
Inspect files, permissions, and ownership.
```

### 3.Command

```bash
ps aux
```

### Usage

```text
Check running processes.
```

### 4.Command

```bash
systemctl status <service>
```

```text
Verify service health.
```

### 5.Command

```bash
journalctl -xe
```

```text
Review logs and identify errors.
```

---


## User & Group Verification

### Scenario Practiced

#### Create a user:

```bash
sudo useradd devuser
```

#### Verify user:

```bash
id devuser
```

#### Check ownership:

```bash
ls -l
```

#### Observation:

- Successfully verified user details and ownership information.

---

## Mini Self-Check

### 1. Which 3 commands save you the most time right now, and why?

```bash
ls -la
```
```text
Quickly shows files, permissions, and ownership.
```
```bash
systemctl status
```
```text
Instantly checks service health.
```
```bash
journalctl
```
```text
Helps identify service and system issues through logs.
```

### 2. How do you check if a service is healthy?

#### Commands I would run:

```bash
systemctl status <service>
ps aux | grep <service>
journalctl -u <service>
```

### 3. How do you safely change ownership and permissions without breaking access?

```text
Example:

sudo chown ubuntu:ubuntu app.log
chmod 644 app.log

This ensures the correct owner has access while maintaining appropriate read permissions for others.
```

### 4. What will you focus on improving in the next 3 days?

- Focusing on being Consistent.
- Practicing more and more commands
- Imporving skill.
- Spending daily a small amount of time in improving vocabulary.
- Practicing hand-on and Creating more projects.

### Key Takeaways

- Consistency is helping commands become second nature.
- Understanding permissions and ownership is essential for system administration.
- Service monitoring and log analysis are critical troubleshooting skills.
- Small daily practice sessions are building a strong Linux foundation.
- Reviewing previous topics helps improve retention and confidence.

--- 

Day 12 Completed!!!
