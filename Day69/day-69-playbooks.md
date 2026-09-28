# Day 69 -- Ansible Playbooks and Modules

## Task

Ad-hoc commands are useful for quick checks, but real automation lives in playbooks. A playbook is a YAML file that describes the desired state of your servers -- which packages to install, which services to run, which files to place where. You write it once, run it a hundred times, and get the same result every time.

Today I wrote Ansible playbooks and practiced the modules and execution options used in day-to-day DevOps automation.

---

## Expected Output

- Multiple playbooks that install packages, manage services, and configure files
- A clear understanding of plays, tasks, modules, and handlers
- A markdown file: `day-69-playbooks.md`

---

# Task 1: Your First Playbook

## Objective

Create an Ansible playbook that installs Nginx on the `web` servers, starts and enables the service, and deploys a custom index page.

Because the EC2 instances run Ubuntu, `apt` was used instead of `yum`.

## `install-nginx.yml`

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

## Execution

The playbook was syntax-checked and executed successfully.

Observed recap:

```text
ok=4
changed=2
unreachable=0
failed=0
```

The Nginx page was verified with `curl` and returned:

```html
<h1>Deployed by Ansible - TerraWeek Server</h1>
```

The playbook was also run again to verify idempotent behavior.

## Result

**Task 1 -- COMPLETE ✅**

---

# Task 2: Understand the Playbook Structure

## Basic Structure

```yaml
---                                    # YAML document start
- name: Play name                      # PLAY -- targets a group of hosts
  hosts: web                           # Which inventory group to run on
  become: true                         # Run tasks as root (sudo)

  tasks:                               # List of TASKS in this play
    - name: Task name                  # TASK -- one unit of work
      module_name:                     # MODULE -- what Ansible does
        key: value                     # Module arguments
```

## 1. What is the difference between a play and a task?

A **play** defines which hosts or inventory group Ansible will target and contains a set of tasks.

A **task** is one individual unit of work inside a play. A task normally uses an Ansible module to make the required change or gather information.

Example:

```yaml
- name: Configure web servers      # PLAY
  hosts: web

  tasks:
    - name: Install Nginx           # TASK
      apt:
        name: nginx
        state: present
```

## 2. Can you have multiple plays in one playbook?

Yes.

A single playbook can contain multiple plays, and each play can target a different inventory group. This is demonstrated in `multi-play.yml`.

Example:

```text
Play 1 → web
Play 2 → app
Play 3 → db
```

## 3. What does `become: true` do at the play level vs the task level?

At the **play level**, `become: true` makes privilege escalation the default for all tasks in that play.

At the **task level**, `become: true` can be used only for a particular task when elevated privileges are required.

Example:

```yaml
- name: Configure web servers
  hosts: web
  become: true
```

or for a single task:

```yaml
- name: Perform privileged task
  become: true
  command: some-command
```

## 4. What happens if a task fails -- do remaining tasks still run?

By default, when a task fails on a host, Ansible stops executing the remaining tasks for that host. Other hosts can continue unless the play is configured with behavior that stops or changes normal failure handling.

---

## Result

**Task 2 -- COMPLETE ✅**

---

# Task 3: Learn the Essential Modules

## Objective

Practice the core modules used for package management, services, files, commands, and configuration changes.

The following modules were practiced:

1. `apt`
2. `service`
3. `copy`
4. `file`
5. `command`
6. `shell`
7. `lineinfile`

`register` and `debug` were also used to capture and display command output.

## `essential-modules.yml`

```yaml
---
- name: Practice essential Ansible modules
  hosts: web
  become: true

  tasks:

    - name: Install curl
      apt:
        name: curl
        state: present
        update_cache: true

    - name: Ensure nginx is running
      service:
        name: nginx
        state: started
        enabled: true

    - name: Create practice file
      copy:
        content: "Ansible module practice\n"
        dest: /tmp/ansible-practice.txt

    - name: Create practice directory
      file:
        path: /tmp/ansible-demo
        state: directory
        mode: '0755'

    - name: Check system uptime
      command: uptime
      register: uptime_result

    - name: Check disk usage
      shell: "df -h | head -5"
      register: disk_result

    - name: Add Ansible managed setting
      lineinfile:
        path: /tmp/ansible-practice.txt
        line: "environment=production"
        state: present

    - name: Display uptime
      debug:
        var: uptime_result.stdout

    - name: Display disk usage
      debug:
        var: disk_result.stdout
```

## What Each Module Does

### `apt`

Used to install or remove packages on Debian/Ubuntu systems.

Example:

```yaml
apt:
  name: curl
  state: present
```

`state: present` means the package should be installed.

### `service`

Used to manage services.

Example:

```yaml
service:
  name: nginx
  state: started
  enabled: true
```

This ensures Nginx is running and enabled to start automatically.

### `copy`

Used to place a file or content on a managed node.

Example:

```yaml
copy:
  content: "Ansible module practice\n"
  dest: /tmp/ansible-practice.txt
```

### `file`

Used to create directories and manage file or directory properties.

Example:

```yaml
file:
  path: /tmp/ansible-demo
  state: directory
  mode: '0755'
```

### `command`

Runs a command without shell processing.

Example:

```yaml
command: uptime
register: uptime_result
```

### `shell`

Runs a command through a shell and supports shell features such as pipes and redirection.

Example:

```yaml
shell: "df -h | head -5"
register: disk_result
```

### `lineinfile`

Ensures that a specific line exists in a file.

Example:

```yaml
lineinfile:
  path: /tmp/ansible-practice.txt
  line: "environment=production"
  state: present
```

### `register`

Stores the result of a task in a variable.

Example:

```yaml
register: uptime_result
```

### `debug`

Displays variables or messages.

Example:

```yaml
debug:
  var: uptime_result.stdout
```

## `command` vs `shell`

### `command`

Use `command` when you only need to execute a normal command and do not need shell features.

Example:

```bash
uptime
```

### `shell`

Use `shell` when the command requires shell functionality such as:

```bash
df -h | head -5
```

The pipe (`|`) is a shell feature, so `shell` is appropriate for that example.

As a general practice, `command` should be preferred when shell features are not needed.

## Execution Result

The playbook was executed successfully with:

```text
ok=10
changed=3
unreachable=0
failed=0
```

The `register` variables captured the command output, and the `debug` tasks displayed it.

## Note on the Assignment's `files/app.conf` Example

The assignment's example also demonstrates copying a file from a `files/` directory:

```yaml
copy:
  src: files/app.conf
  dest: /etc/app.conf
```

The executed version of `essential-modules.yml` used inline `content` with `copy` instead of the `files/app.conf` example above.

## Result

**Task 3 -- COMPLETE ✅**

---

# Task 4: Handlers -- Restart Services Only When Needed

## Objective

Handlers are tasks that run only when a task notifies them. They are useful for service restarts because a restart is only required when the relevant configuration changes.

The intended pattern is:

```yaml
- name: Deploy configuration
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

## How the Handler Works

The configuration task has:

```yaml
notify: Restart Nginx
```

The handler is:

```yaml
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

When the configuration file changes, Ansible notifies the handler. The handler runs at the end of the play.

When the configuration does not change, the handler is not triggered.

## Before / After Comparison

### First run

The configuration file changed, so the handler was triggered.

The first execution showed changes being made.

### Second run

The configuration was already in the desired state.

The second execution showed no additional changes:

```text
changed=0
```

This demonstrates the key purpose of handlers: **avoid unnecessary service restarts**.

## Nginx Validation

The Nginx configuration was validated with:

```bash
nginx -t
```

The validation output confirmed:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

## Result

**Task 4 -- COMPLETE ✅**

---

# Task 5: Dry Run, Diff, and Verbosity

## Objective

Practice the Ansible options used for previewing changes, reviewing differences, troubleshooting, and limiting execution.

---

## 1. Check Mode

Command:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check
```

Observed result:

```text
ok=2
changed=0
unreachable=0
failed=0
skipped=1
```

The Nginx validation command was skipped in check mode.

Check mode is useful for previewing changes without applying them.

---

## 2. Diff Mode

Command:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check --diff
```

Observed result:

```text
ok=2
changed=0
unreachable=0
failed=0
skipped=1
```

No diff appeared because the configuration was already in the desired state.

`--diff` is most useful when a file would actually change, because it can show the before/after difference for supported file operations.

---

## 3. Verbosity

### Verbose

```bash
ansible-playbook -i inventory.ini nginx-config.yml -v
```

The output confirmed:

- Ansible was using default configuration behavior.
- The Nginx configuration file was already correct.
- The configuration task reported `changed: false`.
- `nginx -t` returned return code `0`.
- The Nginx configuration test was successful.

Final recap:

```text
ok=3
changed=0
unreachable=0
failed=0
skipped=0
```

### More verbose

```bash
ansible-playbook -i inventory.ini nginx-config.yml -vv
```

### Connection debugging

```bash
ansible-playbook -i inventory.ini nginx-config.yml -vvv
```

The `-vvv` run provided detailed SSH, privilege-escalation, interpreter, module, and command execution information.

---

## 4. Limit to a Specific Host

Command:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --limit web-server
```

The playbook executed only against:

```text
web-server
```

Final recap:

```text
ok=3
changed=0
unreachable=0
failed=0
skipped=0
```

---

## 5. List Affected Hosts

Command:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --list-hosts
```

Observed:

```text
play #1 (web): Configure Nginx
  hosts (1):
    web-server
```

---

## 6. List Tasks

Command:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --list-tasks
```

Observed tasks:

```text
Deploy custom Nginx configuration
Validate Nginx configuration
```

---

## Why `--check --diff` Is Important for Production

The combination is useful because:

```text
--check → previews what Ansible expects to change
--diff  → shows file differences when supported and when a change exists
```

Together they provide a safer way to review a playbook before applying configuration changes to production systems.

They are not a guarantee that every module behaves exactly like a full execution, so production changes should still be reviewed carefully.

## Result

**Task 5 -- COMPLETE ✅**

---

# Task 6: Multiple Plays in One Playbook

## Objective

Use one playbook with separate plays for:

```text
web
app
db
```

Each play targets a different inventory group.

## `multi-play.yml`

The executed version was:

```yaml
---
- name: Configure web servers
  hosts: web
  become: true

  tasks:
    - name: Ensure Nginx is installed
      apt:
        name: nginx
        state: present
        update_cache: true

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true

    - name: Show web server role
      debug:
        msg: "This server is the WEB layer: {{ inventory_hostname }}"


- name: Configure application servers
  hosts: app
  become: true

  tasks:
    - name: Create application role marker
      copy:
        content: "Application server managed by Ansible\n"
        dest: /tmp/app-server-role.txt
        mode: '0644'

    - name: Show application server role
      debug:
        msg: "This server is the APP layer: {{ inventory_hostname }}"


- name: Configure database servers
  hosts: db
  become: true

  tasks:
    - name: Create database role marker
      copy:
        content: "Database server managed by Ansible\n"
        dest: /tmp/db-server-role.txt
        mode: '0644'

    - name: Show database server role
      debug:
        msg: "This server is the DB layer: {{ inventory_hostname }}"
```

## Syntax Check

Command:

```bash
ansible-playbook -i inventory.ini multi-play.yml --syntax-check
```

Result:

```text
playbook: multi-play.yml
```

✅ Syntax valid.

---

## List Hosts

Command:

```bash
ansible-playbook -i inventory.ini multi-play.yml --list-hosts
```

Observed:

```text
play #1 (web): Configure web servers
  web-server

play #2 (app): Configure application servers
  app-server

play #3 (db): Configure database servers
  db-server
```

✅ Each play targeted the correct inventory group.

---

## List Tasks

Command:

```bash
ansible-playbook -i inventory.ini multi-play.yml --list-tasks
```

Observed:

```text
Play #1: Configure web servers
  Ensure Nginx is installed
  Ensure Nginx is running
  Show web server role

Play #2: Configure application servers
  Create application role marker
  Show application server role

Play #3: Configure database servers
  Create database role marker
  Show database server role
```

✅ All three plays and their tasks were detected.

---

## First Execution

Command:

```bash
ansible-playbook -i inventory.ini multi-play.yml
```

Observed recap:

```text
app-server : ok=3 changed=1 unreachable=0 failed=0
db-server  : ok=3 changed=1 unreachable=0 failed=0
web-server : ok=4 changed=0 unreachable=0 failed=0
```

The debug tasks confirmed:

```text
This server is the WEB layer: web-server
This server is the APP layer: app-server
This server is the DB layer: db-server
```

✅ All three plays executed successfully.

---

## Verification of App and DB Role Markers

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

✅ The correct role-specific files were created on the app and db hosts.

---

## Second Execution -- Idempotency

The playbook was executed again:

```bash
ansible-playbook -i inventory.ini multi-play.yml
```

Observed recap:

```text
app-server : ok=3 changed=0 unreachable=0 failed=0
db-server  : ok=3 changed=0 unreachable=0 failed=0
web-server : ok=4 changed=0 unreachable=0 failed=0
```

✅ No unnecessary changes were made on the second run.

This demonstrates idempotency across all three plays.

## Note on the Assignment's Example Tasks

The assignment's sample `multi-play.yml` uses:

- Node.js build dependencies on `app`
- A MySQL client on `db`
- `/opt/app` and `/var/lib/appdata`

The executed playbook used role-marker files instead, while preserving the required three-play `web` / `app` / `db` structure.

Therefore, the execution proves correct multi-play targeting and idempotency, but it does **not** by itself prove that the assignment's sample MySQL client was installed on `db`.

## Result

**Task 6 -- COMPLETE ✅**

---

# Key Concepts Learned

## Play

A play maps a group of hosts to a collection of tasks.

```yaml
- name: Configure web servers
  hosts: web
```

## Task

A task is one unit of work.

```yaml
- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
```

## Module

A module performs the actual operation.

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

## Handler

A handler is a task triggered by `notify`, commonly used for restarting services only when configuration changes.

## Register

`register` saves task output into a variable.

## Debug

`debug` prints variables or messages.

## Idempotency

An idempotent playbook can be run repeatedly without making unnecessary changes.

The Day 69 exercises demonstrated this with repeated runs showing:

```text
changed=0
```

---

# Final Day 69 Status

| Task | Description | Status |
|---|---|---|
| Task 1 | Your First Playbook | ✅ Complete |
| Task 2 | Understand the Playbook Structure | ✅ Complete |
| Task 3 | Learn the Essential Modules | ✅ Complete |
| Task 4 | Handlers -- Restart Services Only When Needed | ✅ Complete |
| Task 5 | Dry Run, Diff, and Verbosity | ✅ Complete |
| Task 6 | Multiple Plays in One Playbook | ✅ Complete |

## Overall Result

**Day 69 -- COMPLETE ✅**

The Day 69 challenge covered Ansible playbooks, essential modules, handlers, check/diff modes, verbosity, host/task inspection, host limiting, and multi-play automation.

Repeated playbook execution demonstrated Ansible's idempotent behavior, with already-configured resources returning:

```text
changed=0
```

---

# Evidence / Screenshot Checklist

The challenge asks for screenshots/evidence. The following terminal outputs are the relevant evidence to capture in the repository or challenge submission:

## Task 1

First Nginx playbook run:

```bash
ansible-playbook -i inventory.ini install-nginx.yml
```

Second run showing idempotency:

```bash
ansible-playbook -i inventory.ini install-nginx.yml
```

Web verification:

```bash
curl http://<web-server-public-ip>
```

## Task 4

First configuration run showing a change and handler activity:

```bash
ansible-playbook -i inventory.ini nginx-config.yml
```

Second run showing no configuration change:

```bash
ansible-playbook -i inventory.ini nginx-config.yml
```

## Task 5

Check mode:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check
```

Diff mode:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --check --diff
```

Verbose:

```bash
ansible-playbook -i inventory.ini nginx-config.yml -v
```

Very verbose:

```bash
ansible-playbook -i inventory.ini nginx-config.yml -vvv
```

Limit:

```bash
ansible-playbook -i inventory.ini nginx-config.yml --limit web-server
```

## Task 6

Multi-play execution:

```bash
ansible-playbook -i inventory.ini multi-play.yml
```

Second run showing idempotency:

```bash
ansible-playbook -i inventory.ini multi-play.yml
```

---

# Submission

The required documentation file is:

```text
day-69-playbooks.md
```

Submission location:

```text
2026/day-69/day-69-playbooks.md
```

After adding the file to the repository:

```bash
git add 2026/day-69/day-69-playbooks.md
git commit -m "Add Day 69 Ansible playbooks documentation"
git push
```

---

# Cleanup

The AWS infrastructure used for the challenge was provisioned with Terraform.

After all required evidence has been captured and the repository changes have been committed and pushed, the infrastructure can be cleaned up with:

```bash
terraform destroy
```

Before destroying the environment, save any final infrastructure information needed for the challenge:

```bash
terraform output
```

