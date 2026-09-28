# Day 69 – Ansible Playbooks and Modules

> **90 Days of DevOps Challenge – TrainWithShubham**

Day 69 focused on moving from Ansible ad-hoc commands to reusable **Ansible Playbooks** and understanding the modules used for everyday infrastructure automation.

The day covered package installation, service management, file management, command execution, configuration changes, handlers, check/diff modes, verbosity, host limiting, and multi-play automation.

---

## 📌 Day 69 Objectives

- Write and execute Ansible playbooks
- Understand **plays, tasks, modules, and handlers**
- Practice essential Ansible modules
- Configure and manage Nginx
- Validate Ansible playbooks before execution
- Demonstrate **idempotency**
- Use `--check`, `--diff`, `-v`, `-vvv`, `--limit`, `--list-hosts`, and `--list-tasks`
- Manage `web`, `app`, and `db` infrastructure with one playbook

---

## 🏗️ Environment

The Day 69 lab used AWS EC2 instances provisioned with Terraform.

### Server Groups

| Group | Host | Purpose |
|---|---|---|
| `web` | `web-server` | Nginx / Web layer |
| `app` | `app-server` | Application layer |
| `db` | `db-server` | Database layer |

### Control Node

```text
OS: Ubuntu 26.04 LTS
Ansible Core: 2.20.1
Python: 3.14.4
AWS Region: ap-south-1
```

SSH authentication used:

```text
~/.ssh/ansible-key.pem
```

---

## 📁 Project Structure

```text
day69-ansible-infrastructure/
├── install-nginx.yml
├── essential-modules.yml
├── nginx-config.yml
├── multi-play.yml
├── inventory.ini
├── files/
│   ├── app.conf
│   └── nginx.conf
└── 2026/
    └── day-69/
        ├── README.md
        └── day-69-playbooks.md
```

> File names shown above reflect the Day 69 challenge structure. The exact supporting files present in the working environment may vary based on the implementation.

---

# 📝 Tasks Completed

## Task 1 – First Playbook

Created:

```text
install-nginx.yml
```

The playbook:

- Installs Nginx using `apt`
- Starts Nginx
- Enables Nginx at boot
- Deploys a custom HTML page

Example:

```yaml
---
- name: Install and configure Nginx
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: true

    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: true

    - name: Deploy custom index page
      copy:
        content: "<h1>Deployed by Ansible - TerraWeek Server</h1>"
        dest: /var/www/html/index.html
```

### Result

```text
ok=4
changed=2
unreachable=0
failed=0
```

The custom Nginx page was verified successfully with `curl`.

---

# 🧩 Task 2 – Playbook Structure

An Ansible playbook is built from:

```text
Play
 └── Tasks
      └── Modules
```

### Play

Defines the target hosts and the tasks that should run on them.

```yaml
- name: Configure web servers
  hosts: web
```

### Task

A single unit of work.

```yaml
- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
```

### Module

The component that performs the actual operation.

Examples:

```text
apt
service
copy
file
command
shell
lineinfile
debug
```

### `become: true`

Enables privilege escalation, normally through `sudo`.

It can be configured for an entire play:

```yaml
become: true
```

or for a specific task:

```yaml
- name: Privileged task
  become: true
```

### Multiple Plays

One playbook can contain multiple plays targeting different inventory groups.

Example:

```text
web
app
db
```

### Task Failure

By default, when a task fails on a host, Ansible stops executing the remaining tasks for that host.

---

# 🔧 Task 3 – Essential Ansible Modules

The following modules were practiced:

| Module | Purpose |
|---|---|
| `apt` | Install/remove Ubuntu packages |
| `service` | Start, stop, restart, and enable services |
| `copy` | Copy files or content to managed hosts |
| `file` | Manage files, directories, and permissions |
| `command` | Run commands without shell processing |
| `shell` | Run commands with shell features |
| `lineinfile` | Ensure a particular line exists in a file |
| `register` | Save task output into a variable |
| `debug` | Display variables or messages |

### `essential-modules.yml`

The executed playbook practiced package installation, Nginx management, file creation, directory creation, command execution, shell pipelines, line editing, and output display.

Execution result:

```text
ok=10
changed=3
unreachable=0
failed=0
```

---

## `command` vs `shell`

### `command`

Use when a normal command is enough and shell features are not required.

Example:

```yaml
- name: Check uptime
  command: uptime
  register: uptime_result
```

### `shell`

Use when shell features such as pipes or redirects are needed.

Example:

```yaml
- name: Check disk usage
  shell: "df -h | head -5"
  register: disk_result
```

A good general rule is to prefer `command` when shell functionality is unnecessary.

---

# 🔄 Task 4 – Handlers

Handlers are tasks that run only when triggered with `notify`.

Typical configuration pattern:

```yaml
- name: Deploy Nginx config
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: Restart Nginx

handlers:
  - name: Restart Nginx
    service:
      name: nginx
      state: restarted
```

### Why Use Handlers?

A service restart can be unnecessary if its configuration has not changed.

With a handler:

```text
Configuration changes
        ↓
notify handler
        ↓
Restart Nginx
```

When nothing changes:

```text
No configuration change
        ↓
No notification
        ↓
No restart
```

### Idempotency Demonstrated

Repeated executions showed:

```text
changed=0
```

when the system was already in the desired state.

Nginx configuration was also validated with:

```bash
nginx -t
```

Successful validation:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

# 🧪 Task 5 – Dry Run, Diff, and Verbosity

## Check Mode

Preview changes without applying them:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check
```

Observed:

```text
ok=2
changed=0
unreachable=0
failed=0
skipped=1
```

---

## Check + Diff

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check --diff
```

Observed:

```text
ok=2
changed=0
unreachable=0
failed=0
skipped=1
```

No diff appeared because the target configuration was already correct.

### Why `--check --diff`?

```text
--check → preview expected changes
--diff  → inspect supported file differences
```

Together they provide a useful pre-change review before applying configuration.

---

## Verbosity

### Verbose

```bash
ansible-playbook -i inventory.ini nginx-config.yml -v
```

### More verbose

```bash
ansible-playbook -i inventory.ini nginx-config.yml -vv
```

### Connection debugging

```bash
ansible-playbook -i inventory.ini nginx-config.yml -vvv
```

The `-vvv` execution showed detailed SSH connection, privilege escalation, interpreter, module, and command information.

---

## Limit Execution

Run only against one host:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --limit web-server
```

Observed target:

```text
web-server
```

---

## List Hosts

```bash
ansible-playbook -i inventory.ini nginx-config.yml --list-hosts
```

Result:

```text
web-server
```

---

## List Tasks

```bash
ansible-playbook -i inventory.ini nginx-config.yml --list-tasks
```

Tasks observed:

```text
Deploy custom Nginx configuration
Validate Nginx configuration
```

---

# 🌐 Task 6 – Multiple Plays in One Playbook

Created:

```text
multi-play.yml
```

The playbook contains three plays:

```text
Play 1 → web
Play 2 → app
Play 3 → db
```

### Web Play

Target:

```yaml
hosts: web
```

Tasks:

- Ensure Nginx is installed
- Ensure Nginx is running
- Display the web role

### App Play

Target:

```yaml
hosts: app
```

Tasks:

- Create an application role marker
- Display the application role

### DB Play

Target:

```yaml
hosts: db
```

Tasks:

- Create a database role marker
- Display the database role

---

## Multi-Play Validation

Syntax check:

```bash
ansible-playbook -i inventory.ini multi-play.yml --syntax-check
```

Result:

```text
playbook: multi-play.yml
```

### Hosts

```bash
ansible-playbook -i inventory.ini multi-play.yml --list-hosts
```

Detected:

```text
web  → web-server
app  → app-server
db   → db-server
```

### Tasks

```bash
ansible-playbook -i inventory.ini multi-play.yml --list-tasks
```

All three plays and their tasks were detected.

---

## First Execution

```bash
ansible-playbook -i inventory.ini multi-play.yml
```

Observed recap:

```text
app-server : ok=3 changed=1 unreachable=0 failed=0
db-server  : ok=3 changed=1 unreachable=0 failed=0
web-server : ok=4 changed=0 unreachable=0 failed=0
```

The debug messages confirmed:

```text
This server is the WEB layer: web-server
This server is the APP layer: app-server
This server is the DB layer: db-server
```

---

## Verification

Application server:

```bash
ansible app -i inventory.ini -m command -a "cat /tmp/app-server-role.txt"
```

Output:

```text
Application server managed by Ansible
```

Database server:

```bash
ansible db -i inventory.ini -m command -a "cat /tmp/db-server-role.txt"
```

Output:

```text
Database server managed by Ansible
```

---

## Second Execution – Idempotency

```bash
ansible-playbook -i inventory.ini multi-play.yml
```

Second-run recap:

```text
app-server : ok=3 changed=0 unreachable=0 failed=0
db-server  : ok=3 changed=0 unreachable=0 failed=0
web-server : ok=4 changed=0 unreachable=0 failed=0
```

This demonstrates that the playbook did not make unnecessary changes on subsequent execution.

---

# ✅ Day 69 Results

| Task | Status |
|---|---|
| First Ansible playbook | ✅ |
| Playbook structure | ✅ |
| Essential modules | ✅ |
| Handlers | ✅ |
| Check / diff / verbosity | ✅ |
| Multi-play playbook | ✅ |
| Idempotency | ✅ |
| Nginx validation | ✅ |

### Overall

**Day 69 – COMPLETE ✅**

---

# 📸 Evidence Checklist

Recommended screenshots for the challenge submission:

### Task 1
- First `install-nginx.yml` run showing `changed`
- Second run showing `ok`
- `curl` output showing the custom page

### Task 4
- Handler notification on a configuration change
- Second run showing no unnecessary restart/change
- Successful `nginx -t`

### Task 5
- `--check`
- `--check --diff`
- `-v` or `-vvv`
- `--limit`
- `--list-hosts`
- `--list-tasks`

### Task 6
- `multi-play.yml` execution showing `web`, `app`, and `db`
- Second execution showing `changed=0`

---

# 📚 Main Learnings

### 1. Playbooks

Playbooks make infrastructure configuration repeatable and version-controlled.

### 2. Modules

Modules provide specific actions such as package installation, service management, file creation, and configuration editing.

### 3. Handlers

Handlers prevent unnecessary service restarts by running only when notified.

### 4. Idempotency

Running an Ansible playbook repeatedly should converge the system toward the desired state without repeatedly changing already-correct resources.

### 5. Check Mode

`--check` helps preview what Ansible expects to change.

### 6. Diff Mode

`--diff` helps inspect supported file changes.

### 7. Verbosity

`-v`, `-vv`, and `-vvv` provide progressively more execution detail and are useful for troubleshooting.

### 8. Multi-Play Automation

A single playbook can manage different infrastructure layers by targeting different inventory groups.

---

# 🚀 Submission

The required Day 69 documentation file is:

```text
2026/day-69/day-69-playbooks.md
```

The README for this Day 69 directory is:

```text
2026/day-69/README.md
```

Commit and push:

```bash
git add 2026/day-69/
git commit -m "Add Day 69 Ansible playbooks and documentation"
git push
```

---

# 🧹 Cleanup

The lab infrastructure was provisioned using Terraform.

After all required screenshots/evidence have been captured and the Git changes have been committed and pushed:

```bash
terraform output
terraform destroy
```

Do not destroy the infrastructure until all required evidence for the challenge has been captured.

---

## Learn in Public

Suggested LinkedIn post:

> Wrote my first Ansible playbooks today -- installed Nginx, managed services, copied files, and learned handlers. Ran the same playbook twice and it made zero changes the second time. Idempotency is beautiful.
>
> #90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
