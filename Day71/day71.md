# Day 71: Ansible Roles, Templates, Galaxy, and Vault

## Objective

Practice Jinja2 templates, reusable Ansible roles, Ansible Galaxy, and
Ansible Vault, then combine them into a deployment playbook.

> **Important:** This document provides the implementation and
> verification steps. Mark a task complete only after its commands have
> succeeded on your EC2 control node.

## Environment

-   Control node: EC2 instance running Ansible
-   Managed nodes: Ubuntu EC2 instances
-   Project directory: `~/day70/ansible-practice`
-   Inventory: `inventory.ini`
-   Groups: `web`, `app`, and `db`

Use the correct private IPs and SSH settings in your inventory. Never
commit SSH private keys or passwords.

## Task 1 --- Jinja2 template

Create `templates/nginx-vhost.conf.j2` using variables such as
`http_port`, `ansible_hostname`, and `app_name`. Use
`ansible.builtin.template` in `template-demo.yml` to deploy the
configuration. Use `apt` for Ubuntu packages.

``` bash
cd ~/day70/ansible-practice
ansible-playbook -i inventory.ini template-demo.yml --syntax-check
ansible-playbook -i inventory.ini template-demo.yml --diff
ansible web -i inventory.ini -b -m command -a "nginx -t"
```

Adjust the verification path if your playbook uses a different
virtual-host filename.

## Task 2 --- Generate a role structure

``` bash
ansible-galaxy init roles/webserver
ls -R roles/webserver
```

Roles commonly contain `tasks/`, `handlers/`, `templates/`, `defaults/`,
`vars/`, and `meta/`. If the role already exists, inspect it rather than
overwriting your work.

## Task 3 --- Build a custom `webserver` role

Recommended structure:

``` text
roles/webserver/
├── defaults/main.yml
├── handlers/main.yml
├── tasks/main.yml
└── templates/
    ├── nginx.conf.j2
    ├── vhost.conf.j2
    └── index.html.j2
```

Example defaults in `roles/webserver/defaults/main.yml`:

``` yaml
---
http_port: 80
app_name: myapp
max_connections: 512
```

Create `webserver-role-demo.yml`:

``` yaml
---
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

The role tasks should install Nginx with `ansible.builtin.apt`, deploy
configuration and HTML using `ansible.builtin.template`, validate with
`nginx -t`, and ensure the service is enabled and running. Use a handler
to restart Nginx when configuration changes.

``` bash
ansible-playbook -i inventory.ini webserver-role-demo.yml --syntax-check
ansible-playbook -i inventory.ini webserver-role-demo.yml --diff
ansible web -i inventory.ini -b -m command -a "systemctl is-active nginx"
ansible web -i inventory.ini -b -m command -a "nginx -t"
ansible web -i inventory.ini -b -m command -a "curl -s http://127.0.0.1/"
```

## Task 4 --- Install an Ansible Galaxy role

``` bash
ansible-galaxy role install geerlingguy.docker
ansible-galaxy list
```

Create `docker-setup.yml`:

``` yaml
---
- name: Install Docker using an Ansible Galaxy role
  hosts: app
  become: true
  gather_facts: true

  roles:
    - geerlingguy.docker
```

Validate and run:

``` bash
ansible-playbook -i inventory.ini docker-setup.yml --syntax-check
ansible-playbook -i inventory.ini docker-setup.yml
ansible app -i inventory.ini -b -m command -a "docker --version"
```

Example `requirements.yml`:

``` yaml
---
roles:
  - name: geerlingguy.docker
    version: "7.4.1"

  - name: geerlingguy.ntp
```

Install its roles with
`ansible-galaxy role install -r requirements.yml`. If a pinned version
is unavailable or incompatible, use a version compatible with your
environment.

## Task 5 --- Encrypt secrets with Ansible Vault

``` bash
mkdir -p group_vars/db
ansible-vault create group_vars/db/vault.yml
```

Enter practice-only values in the editor:

``` yaml
---
vault_db_password: "REPLACE_WITH_A_PRACTICE_PASSWORD"
vault_db_root_password: "REPLACE_WITH_A_DIFFERENT_PRACTICE_PASSWORD"
vault_api_key: "REPLACE_WITH_A_PRACTICE_KEY"
```

Use your own Vault password. Do not put real credentials in this
document, screenshots, or Git history.

Check encryption:

``` bash
head -n 1 group_vars/db/vault.yml
ansible-vault view group_vars/db/vault.yml
```

The first command should show a header similar to
`$ANSIBLE_VAULT;1.1;AES256`. `ansible-vault view` displays decrypted
contents, so never capture or share secret values.

Create `db-setup.yml`:

``` yaml
---
- name: Verify encrypted database variables
  hosts: db
  gather_facts: true

  tasks:
    - name: Confirm database password is configured
      ansible.builtin.debug:
        msg: "Database password is configured"
      when: vault_db_password is defined and vault_db_password | length > 0
      no_log: true
```

Run:

``` bash
ansible-playbook -i inventory.ini db-setup.yml --syntax-check --ask-vault-pass
ansible-playbook -i inventory.ini db-setup.yml --ask-vault-pass
```

Optional local password file: create `.vault_pass` interactively,
restrict permissions, and add it to `.gitignore`. Example:

``` bash
read -rsp "Enter your Vault password: " VAULT_PASSWORD
echo
umask 077
printf '%s' "$VAULT_PASSWORD" > .vault_pass
unset VAULT_PASSWORD
chmod 600 .vault_pass
touch .gitignore
grep -qxF '.vault_pass' .gitignore || echo '.vault_pass' >> .gitignore
ansible-playbook -i inventory.ini db-setup.yml --vault-password-file .vault_pass
```

Never commit `.vault_pass`. Keep the Vault password separate from the
encrypted file.

## Task 6 --- Combine roles, templates, and Vault

Create `templates/db-config.j2`:

``` jinja2
# Database Configuration -- Managed by Ansible
DB_HOST={{ ansible_default_ipv4.address }}
DB_PORT={{ db_port | default(3306) }}
DB_PASSWORD={{ vault_db_password }}
DB_ROOT_PASSWORD={{ vault_db_root_password }}
```

Create `site-day71.yml` so the existing Day 70 `site.yml` is not
overwritten:

``` yaml
---
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

- name: Configure app servers with the Docker Galaxy role
  hosts: app
  become: true
  gather_facts: true

  roles:
    - geerlingguy.docker

- name: Configure database servers with Vault secrets
  hosts: db
  become: true
  gather_facts: true

  tasks:
    - name: Deploy database configuration securely
      ansible.builtin.template:
        src: templates/db-config.j2
        dest: /etc/db-config.env
        owner: root
        group: root
        mode: '0600'
      no_log: true
```

Ensure the Docker role is installed and `group_vars/db/vault.yml` is
encrypted. Validate syntax:

``` bash
ansible-playbook -i inventory.ini site-day71.yml --syntax-check --ask-vault-pass
```

Then deploy:

``` bash
ansible-playbook -i inventory.ini site-day71.yml --ask-vault-pass
```

Do **not** use `--diff` for this run because the rendered database file
contains secrets.

Verify permissions:

``` bash
ansible db -i inventory.ini -b -m command -a "stat -c '%a %U:%G %n' /etc/db-config.env"
```

Expected: `600 root:root /etc/db-config.env`.

Verify keys without revealing values:

``` bash
ansible db -i inventory.ini -b -m shell -a "sed 's/=.*/=<REDACTED>/' /etc/db-config.env"
```

The file contains passwords, so it should be readable only by root. For
production, review whether writing secrets to a file is appropriate for
the application.

## Task 7 --- Screenshots and GitHub

Create the screenshots directory:

``` bash
mkdir -p screenshots
```

Suggested screenshots (capture only after the step succeeds):

  -----------------------------------------------------------------------
  Filename                            Evidence
  ----------------------------------- -----------------------------------
  `template-demo.png`                 Template playbook run or generated
                                      virtual host

  `webserver-role-structure.png`      `roles/webserver` structure

  `webserver-role.png`                Successful custom role run and
                                      recap

  `nginx-validation.png`              Successful `nginx -t`

  `webserver-page.png`                Sample page returned by `curl`

  `galaxy-install.png`                Galaxy role installation and role
                                      list

  `docker-verify.png`                 Docker version on the app server

  `vault-encrypted.png`               Encrypted Vault header only

  `vault-playbook.png`                Successful Vault playbook run

  `day71-combined-playbook.png`       Combined playbook recap

  `db-config-permissions.png`         `600 root:root` permissions

  `db-config-keys.png`                Keys with values redacted
  -----------------------------------------------------------------------

On Windows, use **Win + Shift + S** and save screenshots into
`screenshots/`. Never include private keys, `.vault_pass`, decrypted
passwords, API keys, or unredacted output.

Example project structure:

``` text
ansible-practice/
├── inventory.ini
├── template-demo.yml
├── webserver-role-demo.yml
├── docker-setup.yml
├── requirements.yml
├── db-setup.yml
├── site-day71.yml
├── templates/
│   ├── nginx-vhost.conf.j2
│   └── db-config.j2
├── group_vars/db/vault.yml
├── roles/webserver/
├── screenshots/
└── day71.md
```

This is illustrative; keep other files required by your actual project
and do not delete Day 70 files.

Review Git status and `.gitignore` before committing:

``` bash
git status
```

After confirming the required branch and repository directory, stage
only safe project files:

``` bash
git add day71.md templates roles group_vars requirements.yml   template-demo.yml webserver-role-demo.yml docker-setup.yml   db-setup.yml site-day71.yml screenshots .gitignore

git status
git commit -m "Complete Day 71 Ansible roles templates and vault"
git push
```

Do not stage `.vault_pass`, private SSH keys, or unencrypted secrets.
Follow your journey's required branch and directory convention if one
was specified.

## Final checklist

-   [ ] Jinja2 template renders successfully.
-   [ ] Custom `webserver` role passes syntax validation and configures
    Nginx.
-   [ ] Galaxy Docker role installs and Docker is verified on the app
    server.
-   [ ] Vault file is encrypted and secret values are not exposed.
-   [ ] Combined playbook passes syntax validation and runs
    successfully.
-   [ ] Database configuration has `0600` permissions and root
    ownership.
-   [ ] Screenshots are captured with secrets redacted.
-   [ ] `.vault_pass` and private keys are excluded from Git.
-   [ ] Documentation is committed and pushed.

## Key concepts

-   **Jinja2 templates:** render configuration dynamically from
    variables and facts.
-   **Ansible roles:** organize automation into reusable tasks,
    handlers, templates, and defaults.
-   **Ansible Galaxy:** provides reusable community roles.
-   **Ansible Vault:** encrypts sensitive variables at rest.
-   **Idempotency:** a well-designed playbook can be run repeatedly
    without making unnecessary changes.
-   **Security:** restrict secret-file permissions, avoid logging
    sensitive values, and keep Vault passwords outside Git.
