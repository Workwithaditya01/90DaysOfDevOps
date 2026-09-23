# Day 68 — Introduction to Ansible and Inventory Setup

This project is part of my **90 Days of DevOps** learning journey. On Day 68, I learned the fundamentals of **Ansible**, created an Ansible control node and managed nodes on AWS, configured an inventory, and practiced Ansible ad-hoc commands.

## 📌 What I Learned

- What Configuration Management is and why it is important
- What Ansible is and how it works
- Ansible's agentless architecture
- Control node vs managed nodes
- Inventory and host groups
- Ansible modules and ad-hoc commands
- SSH-based communication between Ansible nodes
- Group-of-groups using `:children`
- Host patterns such as `web:app` and `all:!db`
- `ansible.cfg` configuration
- `--become` for privilege escalation
- Difference between `command` and `shell` modules
- Basic troubleshooting of SSH and inventory configuration

## 🏗️ Lab Architecture

```text
                         AWS Cloud
                            │
                    ┌───────┴───────┐
                    │ Ansible Control│
                    │     Node       │
                    │    Ubuntu      │
                    └───────┬───────┘
                            │
                         SSH / Ansible
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
     ┌────▼────┐       ┌────▼────┐       ┌────▼────┐
     │   Web   │       │   App   │       │    DB   │
     │ Managed │       │ Managed │       │ Managed │
     │  Node   │       │  Node   │       │  Node   │
     └─────────┘       └─────────┘       └─────────┘
```

### Infrastructure

| Component | Details |
|---|---|
| Cloud | AWS |
| Region | `ap-south-1` |
| OS | Ubuntu 22.04 |
| Instance Type | `t3.micro` |
| Control Node | Ansible installed |
| Managed Nodes | Web, App, DB |
| Connection | SSH |
| Provisioning | Terraform |
| Configuration Management | Ansible |

> **Security note:** Private IP addresses, public IP addresses, private keys, and personal IP addresses should not be committed to a public repository.

---

# 1. What is Configuration Management?

Configuration management is the process of automatically configuring and maintaining servers in a desired state.

Instead of manually connecting to every server and installing packages or changing configuration files, tools such as Ansible can automate these tasks.

### Example

Without configuration management:

```text
SSH → Server 1 → Install Nginx
SSH → Server 2 → Install Nginx
SSH → Server 3 → Install Nginx
```

With Ansible:

```text
Ansible Control Node
        │
        ├── Server 1
        ├── Server 2
        └── Server 3
```

A single command can manage multiple servers.

## Why is it needed?

- Automation
- Consistency
- Repeatability
- Faster server configuration
- Reduced manual errors
- Easier infrastructure maintenance
- Better scalability

---

# 2. Ansible vs Other Configuration Management Tools

| Tool | Architecture | Main Characteristic |
|---|---|---|
| Ansible | Agentless | Uses SSH/WinRM |
| Puppet | Agent-based | Uses Puppet agents |
| Chef | Agent-based | Uses Chef client |
| Salt | Agent-based / agentless options | Remote execution and configuration management |

Ansible is particularly convenient for learning and many infrastructure automation workflows because managed Linux hosts do not need a continuously running Ansible agent.

---

# 3. Ansible Agentless Architecture

Ansible follows an **agentless** architecture.

The control node connects to managed nodes primarily through SSH for Linux systems.

```text
              Control Node
                  │
             Ansible Engine
                  │
                SSH
       ┌──────────┼──────────┐
       ▼          ▼          ▼
     Web        App          DB
   Managed    Managed      Managed
    Node       Node         Node
```

The managed machines do not require a permanently installed Ansible agent.

---

# 4. Ansible Architecture Components

### Control Node

The machine where Ansible is installed and commands/playbooks are executed.

### Managed Nodes

The target servers that Ansible manages.

### Inventory

A file containing the hosts managed by Ansible and their groups.

### Modules

Small units of work used by Ansible to perform tasks such as:

- `ping`
- `command`
- `shell`
- `apt`
- `copy`
- `service`

### Playbooks

YAML files containing repeatable automation instructions. Playbooks are used for more structured and reusable automation than individual ad-hoc commands.

---

# 5. AWS Lab Setup

Terraform was used to provision the AWS infrastructure.

The lab contains:

- 1 Ansible control node
- 1 web managed node
- 1 app managed node
- 1 database managed node

The security groups were configured so that:

```text
My Laptop
    │
    │ SSH
    ▼
Control Node
    │
    │ SSH
    ├──────────► Web Node
    ├──────────► App Node
    └──────────► DB Node
```

The managed nodes allow SSH from the control node's security group.

---

# 6. Installing Ansible

Ansible was installed on the control node.

```bash
sudo apt update
sudo apt install ansible -y
```

Verify the installation:

```bash
ansible --version
```

Example:

```text
ansible [core ...]
  config file = ...
  python version = ...
```

Ansible only needs to be installed on the **control node** for this lab because it communicates with the managed nodes remotely.

---

# 7. Ansible Inventory

The inventory file used in this project is named:

```text
inventory
```

Example inventory:

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

The inventory organizes the servers into logical groups.

```text
web
 └── web1

app
 └── app1

db
 └── db1
```

> Replace the placeholder IP addresses with your own private IP addresses when using this inventory. Do not publish real infrastructure details in a public repository.

---

# 8. Test Ansible Connectivity

Run:

```bash
ansible all -i inventory -m ping
```

Expected result:

```text
web1 | SUCCESS => ...
app1 | SUCCESS => ...
db1 | SUCCESS => ...
```

The `ping` module checks whether Ansible can connect to the managed hosts and execute an Ansible module successfully.

---

# 9. Ansible Ad-Hoc Commands

Ad-hoc commands are useful for performing quick one-time tasks without creating a playbook.

## Check hostname

```bash
ansible all -i inventory -m command -a "hostname"
```

## Check logged-in user

```bash
ansible all -i inventory -m command -a "whoami"
```

Expected output:

```text
ubuntu
```

## Check system uptime

```bash
ansible all -i inventory -m command -a "uptime"
```

## Check memory on the web server

```bash
ansible web -i inventory -m command -a "free -h"
```

## Check disk usage

```bash
ansible all -i inventory -m command -a "df -h"
```

---

# 10. Installing Git with Ansible

Ubuntu uses the `apt` package manager.

```bash
ansible web -i inventory -m apt -a "name=git state=present update_cache=yes" --become
```

### What does `--become` mean?

`--become` allows Ansible to perform tasks with elevated privileges, usually through `sudo`.

For example, installing system packages normally requires root privileges.

```text
Ansible
   │
   └── sudo / become
          │
          ▼
     Install package
```

---

# 11. Copy a File to Managed Nodes

Create a local file:

```bash
echo "Hello from Ansible" > hello.txt
```

Copy it to the web server:

```bash
ansible web -i inventory -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```

Verify the file:

```bash
ansible web -i inventory -m command -a "cat /tmp/hello.txt"
```

Expected output:

```text
Hello from Ansible
```

---

# 12. Group of Groups

Ansible allows groups to be combined using `:children`.

Add the following to the inventory:

```ini
[application:children]
web
app

[all_servers:children]
application
db
```

The structure becomes:

```text
all_servers
├── application
│   ├── web
│   └── app
└── db
```

Now the `application` group targets both the web and app servers.

---

# 13. Target Specific Groups

Ping the application servers:

```bash
ansible application -i inventory -m ping
```

Ping database servers:

```bash
ansible db -i inventory -m ping
```

Ping all servers:

```bash
ansible all_servers -i inventory -m ping
```

---

# 14. Ansible Host Patterns

Host patterns allow more flexible targeting.

## Target web and app

```bash
ansible 'web:app' -i inventory -m ping
```

## Target everything except DB

```bash
ansible 'all:!db' -i inventory -m ping
```

This is useful when an operation should apply to a subset of the infrastructure.

---

# 15. ansible.cfg

Instead of specifying the inventory file and SSH settings every time, Ansible can use an `ansible.cfg` file.

Example:

```ini
[defaults]
inventory = inventory
host_key_checking = False
remote_user = ubuntu
private_key_file = /home/ubuntu/ansible-key.pem
```

Then commands can be simplified.

Instead of:

```bash
ansible all -i inventory -m ping
```

you can use:

```bash
ansible all -m ping
```

### Security note

`host_key_checking = False` can be convenient in a temporary lab environment, but disabling host-key verification reduces SSH protection against unknown or changed host keys. It should be used deliberately, especially outside disposable practice environments.

Also, never commit a private SSH key to Git.

---

# 16. Command vs Shell Module

| Module | Description |
|---|---|
| `command` | Executes a command without a shell |
| `shell` | Executes the command through a shell |

### Command

```bash
ansible all -i inventory -m command -a "hostname"
```

### Shell

```bash
ansible all -i inventory -m shell -a "echo $HOME"
```

Use `command` when shell features are not required. Use `shell` only when shell functionality such as pipes, redirection, or shell variables is actually needed.

---

# 17. Important Ansible Options

### `-i`

Specifies the inventory file.

```bash
-i inventory
```

### `-m`

Specifies the module.

```bash
-m ping
```

### `-a`

Provides arguments to the module.

```bash
-a "hostname"
```

### `--become`

Runs tasks with elevated privileges.

```bash
--become
```

---

# 18. Ad-Hoc Commands vs Playbooks

| Ad-Hoc Commands | Playbooks |
|---|---|
| Quick tasks | Structured automation |
| Usually one-off operations | Repeatable workflows |
| Good for testing | Good for production automation |
| Command-line based | YAML based |
| Less reusable | Highly reusable |

Example ad-hoc command:

```bash
ansible web -i inventory -m command -a "uptime"
```

A playbook can contain multiple tasks and can be stored in Git for reuse.

---

# 19. Troubleshooting

## Inventory file not found

If the file is named `inventory`, use:

```bash
ansible all -i inventory -m ping
```

Do not use `inventory.ini` unless that is the actual filename.

## Permission denied: publickey

Check the private key:

```bash
ls -l /home/ubuntu/ansible-key.pem
```

Set appropriate permissions:

```bash
chmod 400 /home/ubuntu/ansible-key.pem
```

Test SSH manually:

```bash
ssh -i /home/ubuntu/ansible-key.pem ubuntu@<PRIVATE_IP>
```

Also verify that the inventory contains:

```ini
[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/ansible-key.pem
```

## Python interpreter warning

Ansible may display a warning about discovering Python on the managed node. This does not necessarily mean the command failed. If the module returns `SUCCESS`, the task completed successfully.

---

# 20. Key Learnings

- Ansible is a configuration management and automation tool.
- Ansible is agentless for typical Linux SSH management.
- The control node runs Ansible commands and playbooks.
- Managed nodes are the systems being configured.
- Inventory defines which hosts Ansible manages.
- Modules provide reusable units of work.
- Ad-hoc commands are useful for quick tasks.
- `--become` provides privilege escalation when required.
- Groups make large infrastructure easier to manage.
- Host patterns provide flexible targeting.
- `ansible.cfg` reduces repetitive command-line options.
- SSH connectivity and inventory configuration are fundamental to Ansible troubleshooting.

---

# 21. Terraform + Ansible Workflow

This lab demonstrates how Terraform and Ansible can work together.

```text
Terraform
   │
   ├── Create EC2 instances
   ├── Create security groups
   └── Create infrastructure
            │
            ▼
       AWS Infrastructure
            │
            ▼
         Ansible
            │
   ├── Configure servers
   ├── Install packages
   ├── Copy files
   └── Manage services
```

### Terraform

Terraform is responsible for **provisioning infrastructure**.

### Ansible

Ansible is responsible for **configuring and managing the servers after they exist**.

Together, they form a common Infrastructure as Code + Configuration Management workflow.

---

# 22. Screenshots

Suggested screenshots for this project:

- [ ] Ansible installation and `ansible --version`
- [ ] Inventory configuration
- [ ] Successful `ansible all -i inventory -m ping`
- [ ] Hostname command output
- [ ] Uptime command output
- [ ] Group-of-groups configuration
- [ ] Host pattern command output
- [ ] Final `ansible all -m ping` using `ansible.cfg`

Example repository structure:

```text
Day68/
├── README.md
├── inventory
├── ansible.cfg
├── hello.txt
├── screenshots/
│   ├── ansible-version.png
│   ├── inventory.png
│   ├── ping.png
│   ├── ad-hoc-commands.png
│   ├── groups.png
│   └── final-verification.png
└── terraform/
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── data.tf
    └── ec2.tf
```

> Do not commit `.pem` files, Terraform state files containing sensitive information, credentials, or secrets.

Recommended `.gitignore` entries:

```gitignore
*.pem
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
```

Review your project before committing to ensure no sensitive values are exposed.

---

# 23. Submission Checklist

- [x] Ansible installed on control node
- [x] Inventory created
- [x] Web, app, and DB groups configured
- [x] Ansible connectivity tested
- [x] Ad-hoc commands practiced
- [x] `--become` practiced
- [x] File copied using Ansible
- [x] Group-of-groups configured
- [x] Host patterns practiced
- [x] `ansible.cfg` configured
- [ ] Final screenshots added
- [ ] Sensitive information reviewed before pushing
- [ ] Changes committed and pushed to GitHub

---

# 🚀 90 Days of DevOps

**Day 68 completed:** Introduction to Ansible and Inventory Setup.

This lab helped me understand how Ansible can manage multiple servers from a central control node and how Terraform and Ansible can complement each other in a DevOps workflow.

## Tools Used

- AWS EC2
- Terraform
- Ansible
- Linux / Ubuntu
- SSH
- Git & GitHub

---

## 📚 Next Step

The next stage is to move from Ansible ad-hoc commands to **Ansible Playbooks**, where server configuration can be written as repeatable YAML-based automation.
