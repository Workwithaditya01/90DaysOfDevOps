# Day 69 --- Ansible Playbooks and Modules

![Ansible](https://img.shields.io/badge/Ansible-Playbooks-red?logo=ansible)
![Linux](https://img.shields.io/badge/Linux-Ubuntu-orange?logo=ubuntu)
![DevOps](https://img.shields.io/badge/90DaysOfDevOps-Day%2069-blue)

## Overview

Day 69 of the **90 Days of DevOps** journey focused on moving from
individual Ansible commands to structured automation using **Ansible
Playbooks**.

The main topics covered were:

-   Ansible playbooks and playbook structure
-   Essential Ansible modules
-   Idempotency
-   Handlers
-   `register` and `debug`
-   Check mode and diff
-   Verbosity levels
-   Host and task limits
-   Multi-play playbooks
-   Managing different server roles

The infrastructure consisted of three managed Ubuntu servers controlled
remotely through SSH.

  Server         Inventory Group   Role
  -------------- ----------------- --------------------
  `web-server`   `web`             Web server
  `app-server`   `app`             Application server
  `db-server`    `db`              Database server

The Ansible control node was used to manage all three servers.

------------------------------------------------------------------------

## Table of Contents

-   [Overview](#overview)
-   [Infrastructure](#infrastructure)
-   [Task 1 --- First Ansible Playbook](#task-1--first-ansible-playbook)
-   [Task 2 --- Understanding Playbook
    Structure](#task-2--understanding-playbook-structure)
-   [Task 3 --- Essential Ansible
    Modules](#task-3--essential-ansible-modules)
-   [Task 4 --- Ansible Handlers](#task-4--ansible-handlers)
-   [Task 5 --- Check Mode, Diff, Verbosity and
    Limits](#task-5--check-mode-diff-verbosity-and-limits)
-   [Task 6 --- Multi-Play Playbook](#task-6--multi-play-playbook)
-   [Key Learnings](#key-learnings)
-   [Directory Structure](#directory-structure)
-   [Conclusion](#conclusion)

------------------------------------------------------------------------

## Infrastructure

The inventory was organized into three groups:

``` ini
[web]
web-server

[app]
app-server

[db]
db-server
```

Connectivity was verified using:

``` bash
ansible all -i inventory.ini -m ping
```

### Inventory and Connectivity

![Inventory file and successful
ping](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/inventory%20file.png)

------------------------------------------------------------------------

# Task 1 --- First Ansible Playbook

## Objective

Create the first Ansible playbook to install and configure Nginx on the
web server.

### File

`install-nginx.yml`

``` yaml
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

``` bash
ansible-playbook -i inventory.ini install-nginx.yml
```

### First Run

![First run of
install-nginx.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%201%20first%20execution.png)

The first execution modified the server, so the relevant tasks reported
`changed`.

### Idempotency

The playbook was executed a second time to observe Ansible's idempotent
behavior.

  Run          Behavior
  ------------ ---------------------------------------------------------
  First run    Tasks that changed the server reported `changed`
  Second run   Tasks already in the desired state mostly reported `ok`

This demonstrated that Ansible avoids continuously making unnecessary
changes when the desired state has already been achieved.

### Second Run

![Second run of
install-nginx.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%201%20second%20execution.png)

------------------------------------------------------------------------

# Task 2 --- Understanding Playbook Structure

An Ansible playbook is a YAML file containing one or more **plays**.

``` yaml
---
- name: Configure web server
  hosts: web
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```

## Play

A play connects a group of hosts with a collection of tasks.

``` yaml
hosts: web
```

This means the tasks in that play execute against hosts belonging to the
`web` inventory group.

## Task

A task represents one unit of work.

``` yaml
- name: Install Nginx
  apt:
    name: nginx
    state: present
```

## Module

A module performs the actual operation.

Examples:

-   `apt`
-   `service`
-   `copy`
-   `file`
-   `command`
-   `shell`
-   `lineinfile`

The basic relationship is:

``` text
Playbook
   ↓
  Play
   ↓
  Task
   ↓
 Module
```

## Multiple Plays

A single playbook can contain multiple plays.

``` yaml
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

## Become

`become: true` allows Ansible to execute tasks with elevated privileges.

It can be applied at the play level:

``` yaml
- name: Configure server
  hosts: all
  become: true
```

Or at an individual task level:

``` yaml
- name: Install package
  become: true
  apt:
    name: nginx
    state: present
```

Play-level `become` applies to all tasks in that play, while task-level
`become` applies only to that specific task.

## Task Failure

When a task fails on a particular host, Ansible normally stops executing
the remaining tasks for that host. Other hosts can continue executing
their tasks.

------------------------------------------------------------------------

# Task 3 --- Essential Ansible Modules

The following modules were practiced:

  Module         Purpose
  -------------- ----------------------------------------------
  `apt`          Install and manage packages on Debian/Ubuntu
  `service`      Manage services
  `copy`         Copy files from the control node
  `file`         Manage files, directories and permissions
  `command`      Execute commands without shell features
  `shell`        Execute commands using shell features
  `lineinfile`   Ensure a particular line exists in a file

## `apt`

Used to install packages:

``` yaml
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

Because the managed servers were Ubuntu, `apt` was used instead of
`yum`.

## `service`

Used to ensure Nginx is running:

``` yaml
- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
    enabled: true
```

## `copy`

Used to copy an application configuration file from the Ansible control
node:

``` yaml
- name: Copy application configuration
  copy:
    src: files/app.conf
    dest: /etc/app.conf
    owner: root
    group: root
    mode: '0644'
```

The `files/app.conf` file contained:

``` text
APP_NAME=TerraWeek
APP_ENV=development
APP_PORT=8080
```

## `file`

Used to create an application directory:

``` yaml
- name: Create application directory
  file:
    path: /opt/myapp
    state: directory
    owner: ubuntu
    mode: '0755'
```

## `command`

Used to execute a normal command:

``` yaml
- name: Check disk space
  command: df -h
  register: disk_output
```

The output was stored using `register` and later displayed with the
`debug` module.

## `shell`

Used when shell functionality is required:

``` yaml
- name: Count running processes
  shell: ps aux | wc -l
  register: process_count
```

The pipe (`|`) requires shell functionality.

### Command vs Shell

  -----------------------------------------------------------------------
  Feature                 `command`               `shell`
  ----------------------- ----------------------- -----------------------
  Execution               Simple command          Runs through a shell
                          execution               

  Pipes / redirects       Not supported           Supported

  Recommendation          Preferred when shell    Use only when required
                          features are not needed 
  -----------------------------------------------------------------------

## `lineinfile`

Used to ensure a specific line exists in a file:

``` yaml
- name: Set timezone in environment
  lineinfile:
    path: /etc/environment
    line: 'TZ=Asia/Kolkata'
    create: true
```

## `register` and `debug`

The `register` keyword stores the output of a task in a variable:

``` yaml
register: disk_output
```

The stored output can then be displayed:

``` yaml
- name: Print disk space
  debug:
    var: disk_output.stdout_lines
```

### Essential Modules Execution

![Essential modules
execution](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%203%201.png)

### Registered Output

![Debug output of registered
variables](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%203%202.png)

### Managed Server Verification

![Files and directories verified on
server](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%203%203.png)

------------------------------------------------------------------------

# Task 4 --- Ansible Handlers

## Objective

Use handlers to restart Nginx only when its configuration changes.

A **handler** is a special task that runs only when another task
notifies it.

``` yaml
- name: Deploy Nginx config
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: Restart Nginx
```

The handler was defined as:

``` yaml
handlers:

  - name: Restart Nginx
    service:
      name: nginx
      state: restarted
```

## When Configuration Changes

``` text
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

## When Configuration Does Not Change

``` text
Copy configuration
       ↓
No change
       ↓
No notification
       ↓
Nginx is not restarted
```

The playbook was executed twice:

  -----------------------------------------------------------------------
  Run                                 Result
  ----------------------------------- -----------------------------------
  First run                           Configuration changed and the
                                      handler restarted Nginx

  Second run                          Configuration was already correct,
                                      so the handler was not triggered
  -----------------------------------------------------------------------

### Handler Triggered

![Handler triggered on first
run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%204%20first%20execution.png)

### Handler Skipped

![Handler not triggered on second
run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%204%20second%20execution.png)

------------------------------------------------------------------------

# Task 5 --- Check Mode, Diff, Verbosity and Limits

## Check Mode

Check mode allows a playbook to simulate changes without actually
applying them.

``` bash
ansible-playbook -i inventory.ini nginx-config.yml --check
```

It is useful for previewing changes before applying them.

## Check Mode with Diff

The `--diff` option shows differences for supported file-related
modules.

``` bash
ansible-playbook -i inventory.ini nginx-config.yml --check --diff
```

![Check mode with
diff](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20check-diff.png)

## Verbosity

Ansible supports different levels of output verbosity:

``` bash
ansible-playbook -i inventory.ini nginx-config.yml -v
ansible-playbook -i inventory.ini nginx-config.yml -vv
ansible-playbook -i inventory.ini nginx-config.yml -vvv
```

Higher verbosity provides more information and is useful for
troubleshooting.

![Verbose output
-v](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20-v.png)

![Verbose output
-vv](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20-vv.png)

![Verbose output
-vvv](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20-vvv.png)

## Limit

The `--limit` option restricts a playbook to specific hosts.

``` bash
ansible-playbook -i inventory.ini essential-modules.yml --limit web-server
```

This is useful when testing changes on a single server before applying
them more widely.

![Using
--limit](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20--limits.png)

## List Hosts

To see which hosts a playbook would target:

``` bash
ansible-playbook -i inventory.ini nginx-config.yml --list-hosts
```

## List Tasks

To see which tasks are defined in a playbook:

``` bash
ansible-playbook -i inventory.ini nginx-config.yml --list-tasks
```

![List hosts and list
tasks](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%205%20--lists.png)

------------------------------------------------------------------------

# Task 6 --- Multi-Play Playbook

## Objective

Create a single playbook that manages different server roles:

``` text
web-server
app-server
db-server
```

The playbook uses three separate plays.

## Web Servers

The web play installs and starts Nginx:

``` yaml
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

## Application Servers

The application play installs application-related packages:

``` yaml
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

## Database Servers

The database play installs and starts PostgreSQL:

``` yaml
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

The complete playbook was stored as:

``` text
multi-play.yml
```

## Validation

### Syntax Check

``` bash
ansible-playbook -i inventory.ini multi-play.yml --syntax-check
```

### List Tasks

``` bash
ansible-playbook -i inventory.ini multi-play.yml --list-tasks
```

### Execution

``` bash
ansible-playbook -i inventory.ini multi-play.yml
```

### Syntax Check and Task Listing

![Syntax
check](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%206%20--syntax%20check.png)

![List
tasks](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%206%20--list%20task.png)

### Multi-Play Execution

![Multi-play
execution](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/48cdf3e040564e2a0563d49e0ae1445d527feb81/Day69/Images/task%206%20multi-play.png)

------------------------------------------------------------------------

# Key Learnings

During Day 69, I learned how to:

-   Create and execute Ansible playbooks.
-   Understand the relationship between playbooks, plays, tasks and
    modules.
-   Use `apt` to manage Ubuntu packages.
-   Manage services using the `service` module.
-   Copy configuration files using the `copy` module.
-   Create directories and manage permissions using the `file` module.
-   Execute commands using `command`.
-   Use shell features with `shell`.
-   Capture task output using `register`.
-   Display registered output using `debug`.
-   Manage individual lines in configuration files using `lineinfile`.
-   Use handlers to restart services only when configuration changes.
-   Understand Ansible idempotency.
-   Use check mode before applying changes.
-   Inspect configuration differences with `--diff`.
-   Increase troubleshooting information with `-v`, `-vv` and `-vvv`.
-   Restrict playbook execution using `--limit`.
-   Review targeted hosts using `--list-hosts`.
-   Review playbook tasks using `--list-tasks`.
-   Create a multi-play playbook for different server roles.

------------------------------------------------------------------------

# Directory Structure

``` text
Day69/
│
├── ansible/
│   ├── inventory.ini
│   ├── install-nginx.yml
│   ├── essential-modules.yml
│   ├── nginx-config.yml
│   ├── multi-play.yml
│   │
│   └── files/
│       ├── app.conf
│       └── nginx.conf
│
├── terraform/
│   ├── data.tf
│   ├── ec2.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── security-group.tf
│   └── variables.tf
│
├── images/
│
├── day-69-playbooks.md
│
└── README.md
```

------------------------------------------------------------------------

# Conclusion

Day 69 helped me move from running individual Ansible commands to
building structured automation using playbooks.

The most important concepts from this task were:

**Modules → Idempotency → Handlers → Check Mode → Multi-Play
Automation**

These concepts form an important foundation for using Ansible in
real-world DevOps environments where infrastructure needs to be
configured consistently, repeatedly and safely.

------------------------------------------------------------------------

## 90 Days of DevOps

This work is part of my **90 Days of DevOps** learning journey, where I
am building hands-on experience with Linux, Git, Docker, Kubernetes,
Terraform, Ansible, CI/CD and cloud infrastructure.

**Day 69 completed --- Ansible Playbooks and Modules.**
