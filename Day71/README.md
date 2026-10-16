# Day 71 — Ansible Roles, Templates, Galaxy, and Vault

**#90DaysOfDevOps | TrainWithShubham**

This repository documents Day 71 of my DevOps learning journey. The goal was to make Ansible automation reusable, dynamic, and safer by working with **Jinja2 templates, custom roles, Ansible Galaxy, and Ansible Vault**.

## Objectives

- Use Jinja2 templates to generate configuration files from variables and host facts.
- Organize configuration tasks into reusable Ansible roles.
- Install and use community roles from Ansible Galaxy.
- Encrypt sensitive variables with Ansible Vault.
- Combine roles, templates, and encrypted variables in a single deployment playbook.
- Verify configurations and services on managed hosts.

## Lab Environment

- **Control node:** EC2 instance with Ansible installed
- **Managed nodes:** Ubuntu EC2 instances
- **Inventory groups:** `web`, `app`, and `db`
- **Project directory:** `ansible-practice/`

> **Security:** Never commit SSH private keys, Vault passwords, `.vault_pass` files, API keys, real passwords, or decrypted Vault output. Review screenshots and configuration files before publishing the repository.

## Tasks Completed

### Task 1 — Jinja2 templates

Created `templates/nginx-vhost.conf.j2` and used the `ansible.builtin.template` module to render configuration files on web hosts. Templates allow one source file to produce host-specific configuration using variables such as `http_port`, `app_name`, and facts such as `ansible_hostname`.

```bash
ansible-playbook -i inventory.ini template-demo.yml --syntax-check
ansible-playbook -i inventory.ini template-demo.yml --diff
ansible web -i inventory.ini -b -m command -a "nginx -t"
```

### Task 2 — Create a custom Ansible role

Initialized a reusable role with Ansible Galaxy:

```bash
ansible-galaxy init roles/webserver
ls -R roles/webserver
```

The role separates tasks, handlers, templates, defaults, variables, and metadata into dedicated files.

### Task 3 — Configure a web server with the custom role

Built a custom webserver role to install Nginx on Ubuntu, deploy configuration and a sample page, validate the configuration, and ensure the service is enabled and running. A handler restarts Nginx when its configuration changes.

```bash
ansible-playbook -i inventory.ini webserver-role-demo.yml --syntax-check
ansible-playbook -i inventory.ini webserver-role-demo.yml --diff
ansible web -i inventory.ini -b -m command -a "systemctl is-active nginx"
ansible web -i inventory.ini -b -m command -a "nginx -t"
ansible web -i inventory.ini -b -m command -a "curl -s http://127.0.0.1/"
```

### Task 4 — Install a role from Ansible Galaxy

Installed and inspected the community-maintained `geerlingguy.docker` role for Docker setup on app hosts. A `requirements.yml` file records the external roles needed by the project.

```bash
ansible-galaxy role install geerlingguy.docker
ansible-galaxy list
ansible-playbook -i inventory.ini docker-setup.yml --syntax-check
ansible-playbook -i inventory.ini docker-setup.yml
ansible app -i inventory.ini -b -m command -a "docker --version"
```

Review third-party roles and choose compatible versions before using them in production.

### Task 5 — Protect variables with Ansible Vault

Stored sensitive database variables in `group_vars/db/vault.yml`. Ansible Vault encrypts the file at rest.

```bash
mkdir -p group_vars/db
ansible-vault create group_vars/db/vault.yml
head -n 1 group_vars/db/vault.yml
ansible-vault view group_vars/db/vault.yml
ansible-playbook -i inventory.ini db-setup.yml --syntax-check --ask-vault-pass
ansible-playbook -i inventory.ini db-setup.yml --ask-vault-pass
```

The Vault file should begin with an Ansible Vault header. Do not share decrypted output or commit the password used to unlock the file.

### Task 6 — Combine roles, templates, and Vault

The `site-day71.yml` playbook brings the components together: the custom webserver role targets `web`, the Docker Galaxy role targets `app`, and a database configuration template targets `db` using encrypted variables.

```bash
ansible-playbook -i inventory.ini site-day71.yml --syntax-check --ask-vault-pass
ansible-playbook -i inventory.ini site-day71.yml --ask-vault-pass
```

Avoid using `--diff` when rendered configuration may contain secrets. Verify file permissions without displaying sensitive values:

```bash
ansible db -i inventory.ini -b -m command -a "stat -c '%a %U:%G %n' /etc/db-config.env"
ansible db -i inventory.ini -b -m shell -a "sed 's/=.*/=<REDACTED>/' /etc/db-config.env"
```

Expected permissions for the database configuration file: `600 root:root`.

## Project Structure

```text
ansible-practice/
├── inventory.ini
├── template-demo.yml
├── webserver-role-demo.yml
├── docker-setup.yml
├── requirements.yml
├── db-setup.yml
├── site-day71.yml
├── group_vars/
│   └── db/
│       └── vault.yml
├── host_vars/
├── templates/
│   ├── nginx-vhost.conf.j2
│   └── db-config.j2
├── roles/
│   └── webserver/
│       ├── defaults/main.yml
│       ├── handlers/main.yml
│       ├── tasks/main.yml
│       ├── templates/
│       ├── vars/main.yml
│       └── meta/main.yml
└── .gitignore
```

This is the main structure described in the Day 71 documentation. Keep any additional files required by your actual inventory and lab configuration.

## Screenshots and Evidence

The detailed task-by-task documentation and screenshots are available in [`day-71-ansible-roles-templates-vault.md`](day-71-ansible-roles-templates-vault.md). Keep the accompanying `images/` directory beside that Markdown file so its relative image links work on GitHub.

## Key Learnings

- **Jinja2 templates** make configuration dynamic and reusable.
- **Custom roles** keep automation organized and easier to maintain.
- **Ansible Galaxy** provides reusable community roles, which should be reviewed before use.
- **Ansible Vault** protects sensitive values at rest; the Vault password must also be secured.
- **Handlers** run when notified, such as restarting Nginx after a configuration change.
- **Verification commands** help confirm service state, configuration validity, and file permissions without exposing secrets.

## Completion Checklist

- [x] Created and used a Jinja2 template.
- [x] Created a reusable custom webserver role.
- [x] Installed and used a role from Ansible Galaxy.
- [x] Encrypted sensitive variables with Ansible Vault.
- [x] Combined roles, templates, and Vault in a deployment playbook.
- [x] Documented verification commands and screenshots.

## Learn in Public

Made Ansible automation more reusable and secure today by working with Jinja2 templates, custom roles, Ansible Galaxy, and Ansible Vault. This helped me understand how to structure configuration management for multiple server groups while protecting sensitive values.

**What practices do you use to keep Ansible playbooks reusable and secrets secure?**

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
