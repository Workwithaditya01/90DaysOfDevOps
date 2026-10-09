# Day 70 --- Variables, Facts, Conditionals and Loops

> **Challenge:** #90DaysOfDevOps\
> **Day:** 70\
> **Focus:** Ansible variables, facts, conditionals, loops, and server
> health reporting

## Overview

This project demonstrates how Ansible can manage multiple Ubuntu EC2
instances using reusable variables, gathered system facts, conditional
task execution, loops, and a generated server health report.

The Terraform infrastructure was created separately and is reused by
this Ansible project. The playbooks target the existing inventory
groups:

-   `web-server`
-   `db-server`
-   `app-server`

## Objectives

-   Define reusable variables using `group_vars` and `host_vars`.
-   Override variables when running a playbook.
-   Gather and display Ansible facts.
-   Use `when` conditions to control task execution.
-   Use loops to manage users, directories, and packages.
-   Collect server health information and save a report on each managed
    host.

## Project Structure

``` text
~/day70/ansible-practice/
├── inventory.ini
├── group_vars/
│   ├── all.yml
│   ├── web.yml
│   └── db.yml
├── host_vars/
│   └── web-server.yml
├── playbooks/
│   ├── variables-demo.yml
│   ├── site.yml
│   ├── facts-demo.yml
│   ├── conditional-demo.yml
│   ├── loops-demo.yml
│   └── server-report.yml
└── screenshots/
```

> Keep private SSH keys out of this repository. Do not commit `.pem`
> files, passwords, tokens, or other credentials.

## Inventory

The inventory groups the existing instances by role. Use the private IP
addresses that are currently assigned to your instances.

``` ini
[web]
web-server ansible_host=172.31.12.45

[db]
db-server ansible_host=172.31.1.215

[app]
app-server ansible_host=172.31.4.123

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/ansible-practice-key.pem
ansible_python_interpreter=/usr/bin/python3
```

Update the private-key path if your key is stored elsewhere. Private IP
addresses can change if instances are replaced, so verify them against
the current infrastructure before running the playbooks.

Test connectivity:

``` bash
cd ~/day70/ansible-practice
ansible all -i inventory.ini -m ping
```

## Task 1 --- Variables

The variables demonstration uses values such as an application name,
port, directory, and package list.

Example variable concepts:

``` yaml
app_name: terraweek-app
app_port: 8080
app_dir: "/opt/{{ app_name }}"
packages:
  - git
  - curl
  - wget
```

Variables make playbooks easier to reuse and update without editing
every task.

Run the playbook:

``` bash
ansible-playbook -i inventory.ini playbooks/variables-demo.yml
```

Override values from the command line:

``` bash
ansible-playbook -i inventory.ini playbooks/variables-demo.yml \
  -e "app_name=my-custom-app app_port=9090"
```

Because `app_dir` references `app_name`, it should resolve to
`/opt/my-custom-app` when that override is used.

![Port=8080](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/1.1.png)
![Port=9090](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/1.2.png)

## Task 2 --- Group Variables and Host Variables

The project uses variable files to apply settings at different scopes.

### `group_vars/all.yml`

``` yaml
ntp_server: pool.ntp.org
app_env: development
common_packages:
  - vim
  - htop
  - tree
```

### `group_vars/web.yml`

``` yaml
http_port: 80
max_connections: 1000
web_packages:
  - nginx
```

### `group_vars/db.yml`

``` yaml
db_port: 3306
db_packages:
  - mysql-server
```

### `host_vars/web-server.yml`

``` yaml
max_connections: 2000
custom_message: "This is the primary web server"
```

The `web-server` host-specific value of `max_connections` overrides the
value inherited from the `web` group. When running `site.yml`, verify
that the web server reports `max_connections` as `2000`.

Run:

``` bash
ansible-playbook -i inventory.ini playbooks/site.yml
```

![playbooks/site.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/2.1%60.png)

## Task 3 --- Ansible Facts

Facts are system details gathered by Ansible from managed hosts. The
facts playbook displays information such as hostname, operating system,
memory, IP address, and network interfaces.

Useful facts include:

  Fact                             Purpose
  -------------------------------- ------------------------------------------
  `ansible_hostname`               Hostname reported by the managed machine
  `ansible_distribution`           Linux distribution name
  `ansible_distribution_version`   Distribution version
  `ansible_default_ipv4.address`   Default IPv4 address
  `ansible_memtotal_mb`            Total memory in MB
  `ansible_processor_vcpus`        Number of detected vCPUs
  `ansible_interfaces`             Detected network interfaces

Run:

``` bash
ansible-playbook -i inventory.ini playbooks/facts-demo.yml
```

Facts require gathering to be enabled, for example with
`gather_facts: true`.

![ansible-filter](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/3.2.png)
![Playbooks/facts-demo.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/3.3.png)

## Task 4 --- Conditionals

The conditional playbook demonstrates `when` expressions. Conditions can
use facts, group membership, and variable values to decide whether a
task should run.

Examples of conditions used in this exercise include:

``` yaml
when: "'web' in group_names"
```

``` yaml
when: ansible_distribution == "Ubuntu"
```

``` yaml
when: ansible_memtotal_mb < 1024
```

``` yaml
when: app_env == "production"
```

A task can combine conditions using `and` or `or`. For example, a
condition can require a host to belong to the `web` group and have at
least 512 MB of memory.

Run:

``` bash
ansible-playbook -i inventory.ini playbooks/conditional-demo.yml
```

The play recap and task results show which tasks ran and which were
skipped. Review any package-installation tasks before running them,
because they make changes to managed hosts. In this exercise, the
workers are expected to be Ubuntu systems; confirm the distribution from
the facts output.

![playbooks/conditional-demo.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/4.1.png)
![playbooks/conditional-demo.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/4.2.png)
![playbooks/conditional-demo.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/4.3.png)

## Task 5 --- Loops

The loops playbook demonstrates how to repeat a task for each item in a
list. It manages users, directories, and packages on the hosts in the
inventory.

Example loop patterns:

``` yaml
- name: Create multiple directories
  ansible.builtin.file:
    path: "{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - /opt/app/logs
    - /opt/app/config
    - /opt/app/data
    - /opt/app/tmp
```

``` yaml
- name: Install multiple packages
  ansible.builtin.package:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - curl
    - unzip
    - jq
```

The full playbook also loops over user dictionaries, using `item.name`
and `item.groups`.

Check syntax and run:

``` bash
ansible-playbook -i inventory.ini playbooks/loops-demo.yml --syntax-check
ansible-playbook -i inventory.ini playbooks/loops-demo.yml
```

Verify the users:

``` bash
ansible all -i inventory.ini -b -m command -a "id deploy"
ansible all -i inventory.ini -b -m command -a "id monitor"
ansible all -i inventory.ini -b -m command -a "id appuser"
```

Verify the directories:

``` bash
ansible all -i inventory.ini -m shell -a \
  "ls -ld /opt/app/logs /opt/app/config /opt/app/data /opt/app/tmp"
```

**Important:** The exercise creates the `wheel` group, but on Ubuntu
this does not automatically grant sudo privileges. The users created by
this playbook also do not automatically receive SSH access or passwords.

![playbooks/loops-demo.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/5.1.png)
![playbooks/loops-demo.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/5.2.png)
![playbooks/loops-demo.yml](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/855579fb59fa2006ff2443d6a9f211275428aa99/Day70/Images%2070/5.3.png)

## Task 6 --- Server Health Report

The `server-report.yml` playbook gathers information from every managed
host and writes a text report to:

``` text
/tmp/server-report-<inventory_hostname>.txt
```

The report includes:

-   Inventory hostname
-   Operating system and version
-   IP address
-   Total RAM
-   Disk usage for `/`
-   Memory details
-   A list of running services (up to the first 20 lines)
-   Timestamp of the check

The playbook also displays a warning if the disk usage output contains a
percentage from 90% through 100%.

Check syntax:

``` bash
ansible-playbook -i inventory.ini playbooks/server-report.yml --syntax-check
```

Run the report:

``` bash
ansible-playbook -i inventory.ini playbooks/server-report.yml
```

The report files are created on the managed EC2 instances, not on the
control node. The disk alert is a simple threshold check; review the
actual `df -h /` output if you need to investigate a warning.

**Screenshot:** Save the terminal output showing the report and
successful `PLAY RECAP` as `screenshots/server-report.png`.

## Useful Ansible Commands

``` bash
# Test connection to every host
ansible all -i inventory.ini -m ping

# Display the inventory
ansible-inventory -i inventory.ini --graph

# Check a playbook without executing it
ansible-playbook -i inventory.ini playbooks/server-report.yml --syntax-check

# Run a specific playbook
ansible-playbook -i inventory.ini playbooks/server-report.yml

# Run with a variable override
ansible-playbook -i inventory.ini playbooks/variables-demo.yml \
  -e "app_name=my-custom-app app_port=9090"
```

## What I Learned

-   How to define and reuse Ansible variables.
-   How `group_vars` and `host_vars` organize configuration by group and
    host.
-   How to override variables from the command line.
-   How to gather and display Ansible facts.
-   How `when` conditions control task execution.
-   How loops reduce repetitive YAML tasks.
-   How to register command output and use it in later tasks.
-   How to generate and verify per-host health reports.

## Completion Checklist

Mark each item only after you have run and verified it.

-   [ ] Task 1: Variables playbook runs successfully.
-   [ ] Task 2: Group and host variables are verified.
-   [ ] Task 3: Facts are displayed for the managed hosts.
-   [ ] Task 4: Conditional task execution is verified.
-   [ ] Task 5: Loop tasks complete and users/directories are verified.
-   [ ] Task 6: Health reports are generated and read from all three
    hosts.
-   [ ] Screenshots are saved in the `screenshots/` directory.
-   [ ] Documentation is reviewed and committed to Git.

## Git Commit

From the root of the repository where you keep your Day 70 challenge
files, review the changes before committing:

``` bash
git status
git add 2026/day-70/day-70-variables-loops.md
git commit -m "Add Day 70 Ansible variables and loops documentation"
git push
```

Adjust the file path to match the actual location of this Markdown file
in your repository. Only mark tasks complete when their playbooks and
verification commands have succeeded.
