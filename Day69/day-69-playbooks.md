# Day 69 — Ansible Playbooks and Modules

## Table of Contents

- [Overview](#overview)
- [Task 1 — First Ansible Playbook](#task-1--first-ansible-playbook)
- [Task 2 — Understanding Playbook Structure](#task-2--understanding-playbook-structure)
- [Task 3 — Essential Ansible Modules](#task-3--essential-ansible-modules)
- [Task 4 — Ansible Handlers](#task-4--ansible-handlers)
- [Task 5 — Check Mode, Diff, Verbosity and Limits](#task-5--check-mode-diff-verbosity-and-limits)
- [Task 6 — Multi-Play Playbook](#task-6--multi-play-playbook)
- [Key Learnings](#key-learnings)
- [Day 69 Directory Structure](#day-69-directory-structure)
- [Conclusion](#conclusion)

---

## Overview

Day 69 focused on understanding Ansible playbooks, essential Ansible modules, handlers, idempotency, troubleshooting options, and multi-play playbooks.

The infrastructure used for this task consisted of three managed Ubuntu servers:

| Server | Inventory Group | Role |
| --- | --- | --- |
| `web-server` | `web` | Web server |
| `app-server` | `app` | Application server |
| `db-server` | `db` | Database server |

The Ansible control node was used to manage all three servers remotely over SSH.

### 📸 Screenshot — Inventory and connectivity check

> Add a screenshot of `inventory.ini` and the output of `ansible all -i inventory.ini -m ping`.

![Inventory and ping output](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/inventory%20file.png)

*Figure 0: Inventory file and successful ping to all three servers.*

---

## Task 1 — First Ansible Playbook

### Objective

Create the first Ansible playbook to install and configure Nginx on the web server.

### Playbook

**File:** `install-nginx.yml`

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

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true

    - name: Deploy custom index page
      copy:
        content: "<h1>Hello from Ansible</h1>"
        dest: /var/www/html/index.html
        mode: '0644'
```

### Execution

The playbook was executed using:

```bash
ansible-playbook -i inventory.ini install-nginx.yml
```

### 📸 Screenshot — First run

> Add a screenshot of the first playbook run showing tasks as `changed`.

![First run of install-nginx.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%201%20first%20execution.png)

*Figure 1: First run — tasks that modified the server report `changed`.*

### Idempotency

The playbook was executed a second time to observe Ansible's idempotent behavior.

| Run | Behavior |
| --- | --- |
| First run | Tasks that changed the server reported `changed` |
| Second run | Tasks already in the desired state mostly reported `ok` |

This demonstrated that Ansible does not continuously make unnecessary changes when the desired state has already been achieved.

### 📸 Screenshot — Second run (idempotency)

> Add a screenshot of the second run showing `ok` and `changed=0` in the play recap.

![Second run of install-nginx.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%201%20second%20execution.png)

*Figure 2: Second run — tasks report ok, demonstrating idempotency.*

---

## Task 2 — Understanding Playbook Structure

### Playbook

A playbook is a YAML file containing one or more plays.

```yaml
---
- name: Configure web server
  hosts: web
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```

### Play

A play connects a group of hosts with a collection of tasks.

```yaml
hosts: web
```

This means the tasks in that play are executed against the hosts belonging to the `web` inventory group.

### Task

A task represents one unit of work.

```yaml
- name: Install Nginx
  apt:
    name: nginx
    state: present
```

### Module

A module performs the actual operation. Examples:

- `apt`
- `service`
- `copy`
- `file`
- `command`
- `shell`
- `lineinfile`

The basic relationship is:

```text
Playbook
   ↓
Play
   ↓
Task
   ↓
Module
```

### Multiple Plays

A single playbook can contain multiple plays.

```yaml
---
- name: Configure web servers
  hosts: web
  tasks:
    ...

- name: Configure application servers
  hosts: app
  tasks:
    ...

- name: Configure database servers
  hosts: db
  tasks:
    ...
```

### Become

`become: true` allows Ansible to execute tasks with elevated privileges.

It can be applied at the **play level**:

```yaml
- name: Configure server
  hosts: all
  become: true
```

or at an **individual task level**:

```yaml
- name: Install package
  become: true
  apt:
    name: nginx
    state: present
```

Play-level `become` applies to all tasks in that play, while task-level `become` applies only to that specific task.

### Task Failure

When a task fails on a particular host, Ansible normally stops executing the remaining tasks for that host. Other hosts can continue executing their tasks.

This behavior was observed during the essential modules task when Nginx was not installed on the application and database servers.

---

## Task 3 — Essential Ansible Modules

The following modules were practiced:

| Module | Purpose |
| --- | --- |
| `apt` | Install and manage packages on Debian/Ubuntu |
| `service` | Manage services |
| `copy` | Copy files from the control node |
| `file` | Manage files, directories and permissions |
| `command` | Execute commands without shell features |
| `shell` | Execute commands using shell features |
| `lineinfile` | Ensure a particular line exists in a file |

### `apt`

Used to install packages:

```yaml
- name: Install multiple packages
  apt:
    name:
      - git
      - curl
      - wget
      - tree
    state: present
    update_cache: true
```

> Because the managed servers were Ubuntu, `apt` was used instead of `yum`.

### `service`

Used to ensure Nginx is running:

```yaml
- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
    enabled: true
```

### `copy`

Used to copy an application configuration file from the Ansible control node to the managed server:

```yaml
- name: Copy application configuration
  copy:
    src: files/app.conf
    dest: /etc/app.conf
    owner: root
    group: root
    mode: '0644'
```

The source file (`files/app.conf`) contained:

```text
APP_NAME=TerraWeek
APP_ENV=development
APP_PORT=8080
```

### `file`

Used to create an application directory:

```yaml
- name: Create application directory
  file:
    path: /opt/myapp
    state: directory
    owner: ubuntu
    mode: '0755'
```

### `command`

Used to execute a normal command:

```yaml
- name: Check disk space
  command: df -h
  register: disk_output
```

The output was stored using `register` and later displayed with the `debug` module.

### `shell`

Used when shell functionality is required:

```yaml
- name: Count running processes
  shell: ps aux | wc -l
  register: process_count
```

The pipe (`|`) requires shell functionality.

#### Command vs Shell

| Feature | `command` | `shell` |
| --- | --- | --- |
| Execution | Simple command execution | Runs through a shell |
| Pipes, redirects, etc. | Not supported | Supported |
| Recommendation | Preferred when shell features are not needed | Use only when required |

### `lineinfile`

Used to ensure a specific line exists in a file:

```yaml
- name: Set timezone in environment
  lineinfile:
    path: /etc/environment
    line: 'TZ=Asia/Kolkata'
    create: true
```

### `register` and `debug`

The `register` keyword stores the output of a task in a variable:

```yaml
register: disk_output
```

The stored output can then be used:

```yaml
- name: Print disk space
  debug:
    var: disk_output.stdout_lines
```

### 📸 Screenshot — Essential modules playbook run

> Add a screenshot of `essential-modules.yml` running with all tasks and the play recap.

![essential-modules.yml execution](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%203%201.png)

*Figure 3: Execution of the essential modules playbook.*

### 📸 Screenshot — Registered output via `debug`

> Add a screenshot showing the `df -h` and process-count output printed by `debug`.

![Debug output of registered variables](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%203%202.png)

*Figure 4: Registered variables displayed using the `debug` module.*

### 📸 Screenshot — Verification on the managed server

> Add a screenshot of `cat /etc/environment` on the server.

![Files and directories verified on server](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%203%203.png)

*Figure 5: Count running process, Show Process Count and Set timezone in environment line created by the modules.*

---

## Task 4 — Ansible Handlers

### Objective

Use handlers to restart Nginx only when its configuration changes.

A **handler** is a special task that runs only when another task notifies it.

```yaml
- name: Deploy Nginx config
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: Restart Nginx
```

The handler was defined as:

```yaml
handlers:

  - name: Restart Nginx
    service:
      name: nginx
      state: restarted
```

### Flow when configuration changes

```text
Copy configuration
       ↓
Did configuration change?
       ↓
      YES
       ↓
notify: Restart Nginx
       ↓
Handler executes
       ↓
Nginx restarts
```

### Flow when configuration does not change

```text
Copy configuration
       ↓
No change
       ↓
No notification
       ↓
Nginx is not restarted
```

The playbook was executed twice to demonstrate this behavior.

| Run | Result |
| --- | --- |
| First run | Configuration changed and the handler restarted Nginx |
| Second run | Configuration already correct, so the handler was not triggered |

This is an important part of Ansible's idempotent configuration management.

### 📸 Screenshot — First run (handler triggered)

> Add a screenshot showing `RUNNING HANDLER [Restart Nginx]` in the output.

![Handler triggered on first run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%204%20first%20execution.png)

*Figure 6: First run — configuration changed, handler executed.*

### 📸 Screenshot — Second run (handler skipped)

> Add a screenshot of the second run with no handler execution and `changed=0`.

![Handler not triggered on second run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%204%20second%20execution.png)

*Figure 7: Second run — no change, handler not triggered.*

---

## Task 5 — Check Mode, Diff, Verbosity and Limits

### Check Mode

Check mode allows a playbook to simulate changes without actually applying them.

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check
```

It is conceptually similar to previewing planned changes before applying infrastructure changes.


### Check Mode with Diff

The `--diff` option shows differences for supported file-related modules.

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check --diff
```

This is useful when managing configuration files.

### 📸 Screenshot — Check mode with diff

![Check mode with diff](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20check-diff.png)

*Figure 8: Configuration differences shown using `--check --diff`.*

### Verbosity

Ansible supports different levels of output verbosity:

```bash
ansible-playbook -i inventory.ini nginx-config.yml -v
ansible-playbook -i inventory.ini nginx-config.yml -vv
ansible-playbook -i inventory.ini nginx-config.yml -vvv
```

Higher verbosity provides more information and is useful for troubleshooting.

### 📸 Screenshot — Verbose output

![Verbose output](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20-v.png)
![Verbose output](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20-vv.png)
![Verbose output](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20-vvv.png)


*Figure 9: Increased detail using `-v`, `-vv` or `-vvv`.*

### Limit

The `--limit` option restricts a playbook to specific hosts.

```bash
ansible-playbook -i inventory.ini essential-modules.yml --limit web-server
```

Instead of running against all applicable hosts, the playbook is limited to `web-server`. This is useful when testing changes on a single server before applying them more widely.

### 📸 Screenshot — Limit

![Using --limit](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20--limits.png)

*Figure 10: Playbook restricted to `web-server` using `--limit`.*

### List Hosts

To see which hosts a playbook would target:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --list-hosts
```

### List Tasks

To see which tasks are defined in a playbook:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --list-tasks
```

These options are useful for reviewing a playbook before actually executing it.

### 📸 Screenshot — `--list-hosts` and `--list-tasks`

![List hosts and list tasks](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20--lists.png)

*Figure 11: Reviewing targeted hosts and defined tasks before execution.*

---

## Task 6 — Multi-Play Playbook

### Objective

Create a single playbook that manages different server roles.

```text
web-server
app-server
db-server
```

The playbook uses three separate plays.

### Web Servers

The web play installs and starts Nginx:

```yaml
- name: Configure web servers
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: true

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true
```

### Application Servers

The application play installs application-related packages:

```yaml
- name: Configure application servers
  hosts: app
  become: true

  tasks:
    - name: Install application packages
      apt:
        name:
          - git
          - curl
        state: present
        update_cache: true
```

### Database Servers

The database play installs and starts PostgreSQL:

```yaml
- name: Configure database servers
  hosts: db
  become: true

  tasks:
    - name: Install PostgreSQL
      apt:
        name: postgresql
        state: present
        update_cache: true

    - name: Ensure PostgreSQL is running
      service:
        name: postgresql
        state: started
        enabled: true
```

The complete playbook was stored as `multi-play.yml`.

### Validation and Execution

Syntax validation:

```bash
ansible-playbook -i inventory.ini multi-play.yml --syntax-check
```

Task review:

```bash
ansible-playbook -i inventory.ini multi-play.yml --list-tasks
```

Execution:

```bash
ansible-playbook -i inventory.ini multi-play.yml
```

### 📸 Screenshot — Syntax check and list tasks

![Syntax check and list tasks](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%206%20--syntax%20check.png)
![Syntax check and list tasks](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%206%20--list%20task.png)

*Figure 12: Syntax validation and task listing for `multi-play.yml`.*

### 📸 Screenshot — Multi-play execution

![Multi-play execution](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%206%20multi-play.png)

*Figure 13: Running the multi-play playbook across web, app and db servers.*

---

## Key Learnings

During Day 69, I learned how to:

- Create and execute Ansible playbooks.
- Understand the relationship between playbooks, plays, tasks and modules.
- Use `apt` to manage Ubuntu packages.
- Manage services using the `service` module.
- Copy configuration files using the `copy` module.
- Create directories and manage permissions using the `file` module.
- Execute commands using `command`.
- Use shell features with `shell`.
- Capture task output using `register`.
- Display registered output using `debug`.
- Manage individual lines in configuration files using `lineinfile`.
- Use handlers to restart services only when configuration changes.
- Understand Ansible idempotency.
- Use check mode before applying changes.
- Inspect configuration differences with `--diff`.
- Increase troubleshooting information with `-v`, `-vv` and `-vvv`.
- Restrict playbook execution using `--limit`.
- Review targeted hosts using `--list-hosts`.
- Review playbook tasks using `--list-tasks`.
- Create a multi-play playbook for different server roles.

---

## Day 69 Directory Structure

```text
Day69/
└── ansible/
│     ├── inventory.ini
│     ├── install-nginx.yml
│     ├── essential-modules.yml
│     ├── nginx-config.yml
│     ├── multi-play.yml
│     └── files/
│         ├── app.conf
│         └── nginx.conf
│
├── terraform/
│      ├── data.tf
│      ├── ec2.tf
│      ├── outputs.tf
│      ├── providers.tf
│      ├── security-group.tf
│      └── variables.tf
│
└── day-69-playbooks.md
└── images
└── README.md

```

---

## Conclusion

Day 69 helped me move from running individual Ansible commands to building structured automation using playbooks.

The most important concepts from this task were **modules, idempotency, handlers, check mode and multi-play automation**.

These concepts form an important foundation for using Ansible in real-world DevOps environments where infrastructure needs to be configured consistently, repeatedly and safely.
