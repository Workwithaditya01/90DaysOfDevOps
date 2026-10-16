# Day 71 — Ansible Roles, Templates, Galaxy, and Vault

> **#90DaysOfDevOps | TrainWithShubham**
>
> Day 71 focused on making Ansible automation reusable, dynamic, and safer by using **Jinja2 templates, custom roles, Ansible Galaxy, and Ansible Vault**.

## Objective

The goal was to move beyond one large playbook and organize configuration management into reusable components. Templates render configuration files from variables and host facts, roles package related tasks and handlers, Galaxy provides community-maintained roles, and Vault encrypts sensitive values.

## Environment

- **Control node:** EC2 instance with Ansible installed
- **Managed nodes:** Ubuntu EC2 instances
- **Inventory groups:** `web`, `app`, and `db`
- **Project directory:** `ansible-practice/`

> **Security note:** IP addresses and secrets may differ by environment. Never commit SSH private keys, `.vault_pass`, real passwords, API keys, or decrypted Vault output. The screenshots included here are the evidence images supplied with this project; review them for sensitive information before publishing publicly.

## Task 1 — Jinja2 templates

Created a Jinja2 virtual-host template at `templates/nginx-vhost.conf.j2` and used the `ansible.builtin.template` module in `template-demo.yml` to render a configuration file on the managed web hosts.

Templates can use variables and gathered facts, for example `http_port`, `app_name`, and `ansible_hostname`. This avoids maintaining a separate static configuration file for every server.

```bash
ansible-playbook -i inventory.ini template-demo.yml --syntax-check
ansible-playbook -i inventory.ini template-demo.yml --diff
ansible 172.31.12.45 -i inventory.ini -b -m command -a "cat /etc/nginx/conf.d/terraweek-app.conf"
```

**What I learned:** Jinja2 templates generate host-specific configuration from a shared source file. The `template` module also reports changes, which helps keep playbooks idempotent.

![Task 1.1](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/1.1.png)

![Task 1.2](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/1.2.png)

## Task 2 — Create an Ansible role

Initialized a reusable role structure with Ansible Galaxy:

```bash
ansible-galaxy init roles/webserver
ls -R roles/webserver
```

The custom `roles/webserver/` role organizes functionality into these components:

| Path | Purpose |
|---|---|
| `defaults/main.yml` | Default values that can be overridden |
| `tasks/main.yml` | Main configuration steps |
| `handlers/main.yml` | Actions triggered when a task reports a change |
| `templates/` | Reusable Jinja2 configuration and HTML templates |
| `vars/main.yml` | Role variables intended to be less frequently overridden |
| `meta/main.yml` | Role metadata and dependencies |

![Task 2.1 — Role structure](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/2.1.png)

![Task 2.2 ](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/2.2.png)

## Task 3 — Build and run the custom webserver role

The custom role installs Nginx on Ubuntu using `apt`, deploys configuration and a sample page with `ansible.builtin.template`, validates the configuration, and ensures the service is enabled and running. A handler restarts Nginx when its configuration changes.

The role is called from `webserver-role-demo.yml`, allowing the same role to be reused with different variables:

```yaml
- name: Configure web servers using the custom role
  hosts: web
  become: true
  gather_facts: true
  roles:
    - role: webserver
      vars:
        app_name: terraweek
        http_port: 80
        max_connections: 512
```

Verification commands:

```bash
ansible-playbook -i inventory.ini webserver-role-demo.yml --syntax-check
ansible-playbook -i inventory.ini webserver-role-demo.yml --diff
ansible web -i inventory.ini -b -m command -a "systemctl is-active nginx"
ansible web -i inventory.ini -b -m command -a "nginx -t"
ansible web -i inventory.ini -b -m command -a "curl -s http://127.0.0.1/"
```

![Task 3.1 — Role configuration](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/3.1.png)

![Task 3.2 — Role execution](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/3.2.png)

![Task 3.3 — Configuration validation](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/3.3.png)

## Task 4 — Install a community role from Ansible Galaxy

Installed and inspected the community-maintained `geerlingguy.docker` role to automate Docker setup on the `app` host group.

```bash
ansible-galaxy role install geerlingguy.docker
ansible-galaxy list
ansible-playbook -i inventory.ini docker-setup.yml --syntax-check
ansible-playbook -i inventory.ini docker-setup.yml
ansible app -i inventory.ini -b -m command -a "docker --version"
```

A `requirements.yml` file records roles needed by the project so they can be installed consistently on another control node:

```yaml
---
roles:
  - name: geerlingguy.docker
    version: "7.4.1"
  - name: geerlingguy.ntp
```

Use a version compatible with your Ansible version and target operating system. Galaxy roles are third-party code, so review their documentation and permissions before using them in production.

![Task 4.1 — Galaxy role setup](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/4.2.png)

![Task 4.2 — Mysql Search](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/4.3.png)

![Task 4.3 — Role installation evidence](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/4.2.png)

![Task 4.4 — Docker setup verification](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/4.4.png)

![Task 4.5 ](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/4.5.png)

## Task 5 — Encrypt sensitive variables with Ansible Vault

Created encrypted database variables in `group_vars/db/vault.yml`. Vault encrypts the file at rest, so sensitive values are not stored in plain text in the repository.

```bash
mkdir -p group_vars/db
ansible-vault create group_vars/db/vault.yml
head -n 1 group_vars/db/vault.yml
ansible-vault view group_vars/db/vault.yml
```

The encrypted file begins with a header similar to `$ANSIBLE_VAULT;1.1;AES256`. Use `ansible-vault view` only when you need to inspect the decrypted values, and never include its output in screenshots or logs.

The `db-setup.yml` playbook checks that a password variable is configured without printing its value. Run it with the Vault password:

```bash
ansible-playbook -i inventory.ini db-setup.yml --syntax-check --ask-vault-pass
ansible-playbook -i inventory.ini db-setup.yml --ask-vault-pass
```

If using a local password file, restrict its permissions and add it to `.gitignore`. Never commit that file or share its contents.

![Task 5.1 — Vault setup](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/5.1.png)

![Task 5.2 — Encrypted Vault file evidence](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/5.2.png)

![Task 5.3 — Vault playbook verification](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/5.3.png)

![Task 5.4 — Additional Vault evidence](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/5.4.png)

## Task 6 — Combine roles, templates, and Vault

The combined playbook `site-day71.yml` applies the custom webserver role to `web`, the Docker Galaxy role to `app`, and deploys a database configuration file to `db` using encrypted variables.

The database template `templates/db-config.j2` renders values such as the database host, port, and Vault-protected credentials. The destination is configured with root ownership and mode `0600`, limiting access to the root user.

Validate and run the playbook:

```bash
ansible-playbook -i inventory.ini site-day71.yml --syntax-check --ask-vault-pass
ansible-playbook -i inventory.ini site-day71.yml --ask-vault-pass
```

**Do not use `--diff` on the combined deployment** when it may display rendered secrets. Verify file permissions without revealing secret values:

```bash
ansible db -i inventory.ini -b -m command -a "stat -c '%a %U:%G %n' /etc/db-config.env"
ansible db -i inventory.ini -b -m shell -a "sed 's/=.*/=<REDACTED>/' /etc/db-config.env"
```

Expected permissions: `600 root:root /etc/db-config.env`.

![Task 6.1 — Combined playbook execution](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/b327098c76084848507fb9fe43766f258b41305d/Day71/Images%2071/6.1.png)

![Task 6.2 — Final verification evidence](images/6.2.png)

## Project structure

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
      └── 172.31.12.45.yml
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

This is the main Day 71 structure; keep any additional inventory, role files, or configuration files required by your actual setup. The Day 70 playbooks can remain alongside these files.

## Key takeaways

- **Jinja2 templates** make configuration dynamic by combining variables and facts.
- **Ansible roles** group tasks, handlers, defaults, and templates into reusable units.
- **Ansible Galaxy** helps reuse and version community-maintained automation.
- **Ansible Vault** encrypts sensitive variables at rest; access to the Vault password must also be protected.
- **Handlers and idempotency** help avoid unnecessary service restarts and configuration changes.
- **Least privilege** matters: secret-bearing files should have restrictive permissions and must not be printed in logs.

## Final checklist

- [ ] Jinja2 template playbook passes syntax validation and renders the expected configuration.
- [ ] Custom webserver role runs and Nginx configuration validates.
- [ ] Galaxy role is installed and Docker is verified on app hosts.
- [ ] Vault file is encrypted and secret values are not exposed.
- [ ] Combined playbook passes syntax validation and runs successfully.
- [ ] Database configuration file has `0600` permissions and root ownership.
- [ ] Inventory credentials, private keys, and Vault password files are excluded from Git.
- [ ] Screenshots have been checked for sensitive information before publishing.

## Learn in Public

Today I worked on **Ansible Roles, Jinja2 Templates, Ansible Galaxy, and Ansible Vault** as part of my #90DaysOfDevOps journey.

I practiced rendering host-specific configuration, organizing automation into reusable roles, installing a community role, and protecting sensitive variables with Vault. The combined playbook brought these pieces together for web, app, and database hosts.

**The key lesson:** automation becomes easier to maintain when it is reusable, data-driven, and designed with security in mind.

Thanks to **Shubham Londhe and TrainWithShubham** for the learning journey.

What do you prioritize first when building reusable automation: structure, security, or idempotency?

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #Ansible #DevOps #Automation #AWS
