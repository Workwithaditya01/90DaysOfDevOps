# Day 68 — Introduction to Ansible and Inventory Setup

> **90DaysOfDevOps | TrainWithShubham**

## Overview

Day 68 focused on learning the fundamentals of **Ansible**, setting up an Ansible control node, creating an inventory, connecting to remote EC2 instances over SSH, and running ad-hoc commands.

For this lab, I used **Terraform to provision the AWS infrastructure** and then used **Ansible to manage the servers**.

### Expected Output

- Ansible installed on the control node
- Three EC2 managed nodes
- Working grouped inventory
- Successful SSH connectivity through Ansible
- Successful ad-hoc commands
- Inventory groups and patterns configured
- `ansible.cfg` configured so the inventory does not need to be specified every time

---

# Task 1 — Understand Ansible

## 1. What is Configuration Management?

Configuration management is the practice of maintaining servers and systems in a consistent and desired state.

Instead of manually logging into every server to install packages, configure services, create users, or modify configuration files, a configuration management tool can automate these operations.

### Why do we need it?

Configuration management helps with:

- Automation
- Consistency between servers
- Repeatability
- Faster server setup
- Reduced manual errors
- Easier scaling
- Maintaining a desired system state

## 2. Ansible vs Chef, Puppet, and Salt

| Tool | General approach |
|---|---|
| **Ansible** | Agentless by default; commonly uses SSH for Linux/Unix systems |
| **Chef** | Commonly uses a client/agent architecture and Ruby-based configuration |
| **Puppet** | Commonly uses an agent/server architecture and declarative manifests |
| **Salt** | Provides remote execution and configuration management; supports agent-based and agentless approaches |

The main feature I focused on in this lab is that Ansible can manage Linux servers without installing a permanent Ansible agent on each managed node.

## 3. What does Agentless mean?

Agentless means the managed servers do not need a permanently running Ansible agent.

For this Linux lab, Ansible connects to the managed nodes using **SSH** and executes modules remotely.

The basic flow is:

```text
Control Node
     |
     | SSH
     v
Managed Node
```

## 4. Ansible Architecture

```text
                         Ansible Control Node
                         Ubuntu EC2
                         Ansible installed
                                |
                                | SSH
              +-----------------+-----------------+
              |                 |                 |
              v                 v                 v
           web1 EC2          app1 EC2          db1 EC2
         Managed Node       Managed Node       Managed Node

Inventory  -> Defines hosts and groups
Modules    -> Perform individual tasks
Playbooks  -> YAML files containing repeatable automation
```

### Components

**Control Node** — The machine where Ansible is installed and commands/playbooks are executed.

**Managed Nodes** — The remote servers that Ansible configures.

**Inventory** — The list of managed hosts and their groups.

**Modules** — Units of work such as `ping`, `command`, `copy`, `apt`, and `service`.

**Playbooks** — YAML files that define repeatable automation.

---

# Task 2 — Set Up the Lab Environment

I selected **Option A: Terraform** because I had already learned Terraform and wanted to use it to provision the infrastructure.

## Lab Details

| Role | OS | Instance Type | Purpose |
|---|---|---|---|
| Control Node | Ubuntu 22.04 | t3.micro | Runs Ansible |
| Web | Ubuntu 22.04 | t3.micro | Managed node |
| App | Ubuntu 22.04 | t3.micro | Managed node |
| DB | Ubuntu 22.04 | t3.micro | Managed node |

**AWS Region:** `ap-south-1`

The control node has public SSH access from my allowed IP. The managed nodes are accessed from the control node using their private IP addresses.

## Network Architecture

```text
My Laptop
    |
    | SSH
    v
+----------------------+
| Ansible Control EC2  |
| Ubuntu               |
| Ansible installed    |
+----------+-----------+
           |
           | SSH using private IPs
           |
     +-----+-----+-----+
     |           |     |
     v           v     v
   web1        app1   db1
   EC2         EC2    EC2
```

The managed-node security group allows SSH from the control-node security group. This means direct SSH from my laptop to the managed nodes is intentionally not required.

> **Security:** Public repositories should not contain private SSH keys, AWS credentials, or unnecessary infrastructure details. IP addresses can also be redacted before publishing.

**Screenshot — AWS/Terraform lab infrastructure**

![terraform output](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/terraform%20apply%20output.png)

---

# Task 3 — Install Ansible

I installed Ansible on the **control node**.

The managed nodes do not need Ansible installed because the control node runs Ansible and connects to the managed nodes through SSH.

## Installation

```bash
sudo apt update
sudo apt install ansible -y
```

## Verify Installation

```bash
ansible --version
```

The output confirmed the Ansible version, configuration path, Python version, and related information.

**Screenshot — Ansible installation and version**

![ansible installation](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/ansible%20installation.png)

### Why only the control node?

The control node is responsible for running Ansible commands and playbooks. The managed nodes only need to be reachable through SSH and have the required runtime support for the modules being used.

---

# Task 4 — Create the Inventory File

I created the Ansible project directory:

```bash
mkdir ~/ansible
cd ~/ansible
```

My inventory file is named **`inventory`** rather than `inventory.ini`.

## Inventory

```ini
[web]
web1 ansible_host=<WEB_PRIVATE_IP>

[app]
app1 ansible_host=<APP_PRIVATE_IP>

[db]
db1 ansible_host=<DB_PRIVATE_IP>

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/ansible-key.pem
```

The challenge uses `ec2-user` because its example assumes Amazon Linux. My lab uses **Ubuntu**, so I use `ubuntu`.

The private IP addresses are used because Ansible connects from the control EC2 instance to the managed EC2 instances inside AWS.

## Verify Connectivity

```bash
ansible all -i inventory -m ping
```

The result was successful for all three managed nodes:

```text
web1 | SUCCESS
"ping": "pong"

app1 | SUCCESS
"ping": "pong"

db1 | SUCCESS
"ping": "pong"
```

This confirmed that:

- The inventory was parsed successfully
- SSH authentication worked
- The control node could reach all managed nodes
- Ansible modules could execute remotely

**Screenshot — Successful Ansible ping**

![ping inventory](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/ping%20command%20execution.png)

---

# Task 5 — Run Ad-Hoc Commands

Ad-hoc commands allow quick one-time tasks to be executed without creating a playbook.

## 1. Check Hostname

```bash
ansible all -i inventory -m command -a "hostname"
```

Successful output showed the hostname of each EC2 instance.

Example:

```text
web1 | CHANGED | rc=0 >>
ip-172-31-35-136

app1 | CHANGED | rc=0 >>
ip-172-31-26-120

db1 | CHANGED | rc=0 >>
ip-172-31-14-131
```

**Screenshot — Hostname command**

![Hostname command](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/hostname%20and%20whoami%20command%20execution.png)

## 2. Check Current User

```bash
ansible all -i inventory -m command -a "whoami"
```

All three servers returned:

```text
ubuntu
```

This confirmed that Ansible was connecting using the `ubuntu` user.

**Screenshot — whoami command**

![whoami command](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/hostname%20and%20whoami%20command%20execution.png)


## 3. Check Uptime

```bash
ansible all -i inventory -m command -a "uptime"
```

This displays the uptime and load information of all managed nodes.

## 4. Check Free Memory on Web Servers

```bash
ansible web -i inventory -m command -a "free -h"
```

Because the target is `web`, only `web1` is targeted.

## 5. Check Disk Space

```bash
ansible all -i inventory -m command -a "df -h"
```

This checks filesystem usage on all managed nodes.

## 6. Install a Package on the Web Group

Because the lab uses Ubuntu, I used the `apt` module instead of `yum`.

```bash
ansible web -i inventory -m apt -a "name=git state=present" --become
```

### What does `--become` do?

`--become` enables privilege escalation, similar to using `sudo`.

It is required for tasks that need administrator privileges, such as:

- Installing packages
- Managing services
- Modifying protected system files
- Creating system-level users

## 7. Copy a File to All Servers

Create the file on the control node:

```bash
echo "Hello from Ansible" > hello.txt
```

Copy it to all managed nodes:

```bash
ansible all -i inventory -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```

## 8. Verify the File

```bash
ansible all -i inventory -m command -a "cat /tmp/hello.txt"
```

Expected output:

```text
Hello from Ansible
```

**Screenshot — File copied and verified**

![file validation](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/file%20validation%20.png)

---

# Task 6 — Explore Inventory Groups and Patterns

## 1. Create a Group of Groups

I added the following to the inventory:

```ini
[application:children]
web
app

[all_servers:children]
application
db
```

This creates a group named `application` containing the `web` and `app` groups.

Then `all_servers` contains `application` and `db`.

### Group Structure

```text
application
├── web
│   └── web1
└── app
    └── app1
```

```text
all_servers
├── application
│   ├── web
│   │   └── web1
│   └── app
│       └── app1
└── db
    └── db1
```

## 2. Run Commands Against Groups

### Application group

```bash
ansible application -i inventory -m ping
```

Expected targets:

```text
web1
app1
```

### DB group

```bash
ansible db -i inventory -m ping
```

Expected target:

```text
db1
```

### All servers group

```bash
ansible all_servers -i inventory -m ping
```

Expected targets:

```text
web1
app1
db1
```

**Screenshot — Group targeting**

![group execution](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/group%20command%20ping%20execution.png)

## 3. Use Patterns

### OR pattern

```bash
ansible 'web:app' -i inventory -m ping
```

This targets hosts in either the `web` or `app` groups.

Expected targets:

```text
web1
app1
```

### NOT pattern

```bash
ansible 'all:!db' -i inventory -m ping
```

This targets everything except the `db` group.

Expected targets:

```text
web1
app1
```

**Screenshot — Ansible patterns**

![db ping](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/group%20command%20ping%20execution.png)

## 4. Create `ansible.cfg`

To avoid typing `-i inventory` every time, I created an `ansible.cfg` file in the project directory.

```ini
[defaults]
inventory = inventory
host_key_checking = False
remote_user = ubuntu
private_key_file = /home/ubuntu/ansible-key.pem
```

These values are adapted to my Ubuntu lab. The original challenge example uses `inventory.ini`, `ec2-user`, and a different key path.

Now I can run:

```bash
ansible all -m ping
```

without specifying the inventory file.

## Verification

```bash
ansible all -m ping
```

Expected result:

```text
web1 | SUCCESS
app1 | SUCCESS
db1 | SUCCESS
```

**Screenshot — Final `ansible.cfg` verification**

![ansible.cfg](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/ansible.cfg%20file%20and%20execution.png)

> **Security note:** `host_key_checking = False` is convenient for a temporary learning lab, but disabling host-key verification reduces SSH protection against unexpected host changes. For production environments, use proper host-key management.

---

# Command vs Shell Module

## `command` Module

The `command` module executes a command directly without invoking a shell.

Example:

```bash
ansible all -m command -a "hostname"
```

Use it for straightforward commands when shell features are not needed.

## `shell` Module

The `shell` module executes commands through a shell and therefore supports shell features.

Example:

```bash
ansible all -m shell -a "df -h | grep '/$'"
```

Shell features include:

- Pipes `|`
- Redirection `>`
- Shell operators
- Environment expansion

## Difference

| Feature | `command` | `shell` |
|---|---|---|
| Simple commands | Yes | Yes |
| Pipes | No | Yes |
| Redirection | No | Yes |
| Shell operators | No | Yes |
| Preferred when shell features are unnecessary | Yes | No |

### Rule of thumb

Use `command` when a simple command is enough. Use `shell` only when shell functionality is actually required.

---

# Key Learnings

- Ansible is a configuration management and automation tool.
- Ansible can manage Linux servers without a permanent agent.
- SSH is used for communication with Linux managed nodes.
- The control node runs Ansible.
- The inventory defines hosts and groups.
- Modules perform individual operations.
- Ad-hoc commands are useful for quick tasks.
- `--become` provides privilege escalation similar to `sudo`.
- Inventory groups can contain other groups.
- Ansible patterns can select or exclude groups.
- `ansible.cfg` can provide project-level defaults.
- Terraform and Ansible complement each other: Terraform provisions infrastructure, while Ansible configures and manages servers.

---

# Terraform + Ansible Workflow

```text
Terraform
   |
   | Provision
   v
AWS Infrastructure
   |
   +---- Control EC2
   +---- Web EC2
   +---- App EC2
   +---- DB EC2
              |
              | SSH
              v
           Ansible
              |
              | Configure / Manage
              v
       Managed EC2 Servers
```

### Terraform

Terraform answers:

> **What infrastructure should exist?**

Examples:

- EC2 instances
- Security groups
- Networking
- AWS resources

### Ansible

Ansible answers:

> **How should those servers be configured and maintained?**

Examples:

- Install packages
- Copy configuration files
- Configure services
- Manage users
- Start or stop services

So the workflow becomes:

```text
Terraform → Provision infrastructure
Ansible   → Configure infrastructure
```

---

# Troubleshooting Notes

## Inventory Path

The challenge example uses `inventory.ini`, while my actual file is named `inventory`.

Therefore I use:

```bash
-i inventory
```

instead of:

```bash
-i inventory.ini
```

## SSH Authentication

The inventory specifies the Ubuntu user and private key:

```ini
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/ansible-key.pem
```

The key should have restrictive permissions:

```bash
chmod 400 /home/ubuntu/ansible-key.pem
```

## Python Interpreter Warning

During the lab, Ansible reported that it discovered Python at:

```text
/usr/bin/python3.14
```

This was a warning rather than a connection failure. The Ansible commands still returned successful results such as:

```text
SUCCESS
"ping": "pong"
```

---

# Final Verification

The final verification command is:

```bash
ansible all -m ping
```

The desired result is a successful response from:

```text
web1
app1
db1
```

with:

```text
SUCCESS
"ping": "pong"
```

**Screenshot — Final Day 68 verification**

![all servers ping](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/f0fa501b1d155956373c2e693386716720a0d549/Day68/task%20images/all%20server%20ping%20execution.png)

---

# Submission Checklist

- [x] Ansible installed on control node
- [x] Three EC2 managed nodes provisioned with Terraform
- [x] Inventory created
- [x] SSH connectivity verified
- [x] `ansible all -i inventory -m ping` successful
- [x] Ad-hoc commands executed
- [x] Inventory groups created
- [x] Inventory patterns tested
- [x] `ansible.cfg` configured
- [ ] Add screenshots to the repository
- [ ] Save this file as `day-68-ansible-intro.md`
- [ ] Commit and push to the Day 68 directory

## Suggested Repository Structure

```text
2026/day-68/
├── day-68-ansible-intro.md
└── screenshots/
    ├── task-2-aws-instances.png
    ├── task-3-ansible-version.png
    ├── task-4-ansible-ping.png
    ├── task-5-hostname.png
    ├── task-5-whoami.png
    ├── task-5-copy-file.png
    ├── task-6-groups.png
    ├── task-6-patterns.png
    ├── task-6-ansible-config.png
    └── day-68-final-ping.png
```

> **Before pushing:** Redact public/private IP addresses if desired and never commit `*.pem`, AWS credentials, access keys, or other secrets.

---

# Learn in Public

Started the Ansible journey today — set up a control node, created an inventory with three EC2 instances, and ran ad-hoc commands to manage all servers from one terminal. No agents installed on the managed nodes; Ansible works over SSH.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Ansible` `#DevOps`
