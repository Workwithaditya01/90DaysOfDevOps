# Day 72 -- Ansible Project: Automate Docker and Nginx Deployment

## Overview

Over the last five days I learned Ansible inventory, ad-hoc commands, playbooks, modules, handlers, variables, facts, conditionals, loops, roles, templates, Galaxy and Vault. Today I combined all of it into one project.

**Goal:** go from a fresh Ubuntu server to a running, production-style setup with one command:

- Docker installed and a containerized app running
- Nginx as a reverse proxy on port 80
- Docker Hub credentials encrypted with Vault
- Everything organized as Ansible roles

**Real-life analogy:** opening a new restaurant branch. Terraform rents the building, the `common` role sets up basics (electricity, clock, staff account), the `docker` role installs the kitchen and cooks the meal, `nginx` is the receptionist at the front door, and Vault is the locked envelope holding the safe code.

---

## Architecture

```
Ansible (control node)
   |
   |  SSH
   v
Server [ Nginx:80  ->  Docker Container:8080 ]
```

```
Visitor --> :80 [Nginx reverse proxy] --> 127.0.0.1:8080 [Docker container, app on port 80]
```

| Component | Tool | Purpose |
|---|---|---|
| Infrastructure | Terraform | Creates the EC2 managed node and security group |
| Configuration | Ansible | Configures the server over SSH |
| Application | Docker | Runs the app in an isolated container |
| Front door | Nginx | Public entry point on port 80, proxies to the container |
| Secrets | Ansible Vault | Encrypts Docker Hub credentials |

**Environment**

- Control node: Ubuntu EC2 (`172.31.0.50`), runs Terraform and Ansible
- Managed node: Ubuntu 24.04, `t3.micro`, region `ap-south-1`, created by Terraform
- Ansible user: `ubuntu`, SSH key pair `ansible-practice-key`

---


## Task 1: Project Structure

```
ansible-docker-project/   (~/72-Day/ansible)
  ansible.cfg
  inventory.ini
  site.yml
  .gitignore
  group_vars/
    all.yml
    web/
      vars.yml
      vault.yml            # encrypted
  roles/
    common/
      tasks/main.yml
    docker/
      tasks/main.yml
      handlers/main.yml
      defaults/main.yml
      templates/docker-compose.yml.j2   # reserved for multi-container extension
    nginx/
      tasks/main.yml
      handlers/main.yml
      defaults/main.yml
      templates/
        nginx.conf.j2
        app-proxy.conf.j2
```

![Project tree](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a33450397179891c93263d73b97abb07d0a364a1/Day72/Day72-Screenshots/tree%20structure.png)

### Why each piece exists

| File / Directory | Purpose |
|---|---|
| `ansible.cfg` | Default settings (inventory, user, key, vault password file), so commands stay short |
| `inventory.ini` | The address book: which servers exist and the `[web]` group |
| `site.yml` | Master playbook that applies roles to host groups |
| `group_vars/all.yml` | Variables for every server |
| `group_vars/web/vars.yml` | Variables for the `web` group (ports, server name) |
| `group_vars/web/vault.yml` | Encrypted secrets, kept separate so the rest stays readable in Git |
| `roles/` | Reusable units of work: `common`, `docker`, `nginx` |
| `.gitignore` | Keeps `.vault_pass`, `*.pem` and `*.retry` out of Git |

### `ansible.cfg`

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
remote_user = ubuntu
private_key_file = ~/.ssh/ansible-practice-key.pem
vault_password_file = .vault_pass
```

### `inventory.ini`

```ini
[web]
web-1 ansible_host=15.252.180.68

[web:vars]
ansible_python_interpreter=/usr/bin/python3
```

Connectivity check:

```bash
ansible all -m ping
```

![Ansible ping](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/a33450397179891c93263d73b97abb07d0a364a1/Day72/Day72-Screenshots/connectivity%20check.png)

---

## Task 2: `common` Role

Baseline setup that runs on every server.

**`group_vars/all.yml`**

```yaml
---
timezone: Asia/Kolkata
project_name: devops-app
app_env: development
common_packages:
  - vim
  - curl
  - wget
  - git
  - htop
  - tree
  - jq
  - unzip
```

**`roles/common/tasks/main.yml`**

```yaml
---
- name: Update apt package cache
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: 3600
  tags: common

- name: Install common packages
  ansible.builtin.apt:
    name: "{{ common_packages }}"
    state: present
  tags: common

- name: Set hostname
  ansible.builtin.hostname:
    name: "{{ inventory_hostname }}"
  tags: common

- name: Set timezone
  community.general.timezone:
    name: "{{ timezone }}"
  tags: common

- name: Create deploy user
  ansible.builtin.user:
    name: deploy
    groups: sudo
    append: true
    shell: /bin/bash
    state: present
  tags: common
```

**Ubuntu changes from the task sheet:** `yum` became `apt`, group `wheel` became `sudo`. `cache_valid_time` keeps the cache task idempotent, and `append: true` adds the group without removing existing ones.

**Result:** the second run showed `ok=6 changed=0`, and verification confirmed hostname `web-1`, timezone `IST`, user `deploy` in the `sudo` group, and `jq 1.7` installed.

![Common role run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/d9c576dcdbd2a71dece3d42d5b8c9f0af25706fb/Day72/Day72-Screenshots/site.yml%20common-1.png)
![Common verification](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/Common%20verification.png)

---

## Task 3: `docker` Role

**`roles/docker/defaults/main.yml`**

```yaml
---
docker_app_image: nginx
docker_app_tag: latest
docker_app_name: myapp
docker_app_port: 8080
docker_container_port: 80
```

**`roles/docker/tasks/main.yml`**

```yaml
---
- name: Install prerequisite packages
  ansible.builtin.apt:
    name:
      - ca-certificates
      - curl
      - gnupg
      - apt-transport-https
      - acl
    state: present
    update_cache: true
    cache_valid_time: 3600
  tags: docker

- name: Create apt keyrings directory
  ansible.builtin.file:
    path: /etc/apt/keyrings
    state: directory
    mode: "0755"
  tags: docker

- name: Download Docker GPG key
  ansible.builtin.get_url:
    url: https://download.docker.com/linux/ubuntu/gpg
    dest: /etc/apt/keyrings/docker.asc
    mode: "0644"
  tags: docker

- name: Add Docker apt repository
  ansible.builtin.apt_repository:
    repo: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
    filename: docker
    state: present
  tags: docker

- name: Install Docker CE, Compose plugin and Python Docker SDK
  ansible.builtin.apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
      - python3-docker
    state: present
  tags: docker

- name: Configure Docker log rotation
  ansible.builtin.copy:
    dest: /etc/docker/daemon.json
    content: |
      {
        "log-driver": "json-file",
        "log-opts": { "max-size": "10m", "max-file": "3" }
      }
    owner: root
    group: root
    mode: "0644"
  notify: Restart Docker
  tags: docker

- name: Start and enable Docker service
  ansible.builtin.service:
    name: docker
    state: started
    enabled: true
  tags: docker

- name: Apply pending Docker restart now
  ansible.builtin.meta: flush_handlers
  tags: docker

- name: Add deploy user to docker group
  ansible.builtin.user:
    name: deploy
    groups: docker
    append: true
  tags: docker

- name: Log in to Docker Hub
  community.docker.docker_login:
    username: "{{ vault_docker_username }}"
    password: "{{ vault_docker_password }}"
  become_user: deploy
  no_log: true
  when: vault_docker_username is defined
  tags: docker

- name: Pull application image
  community.docker.docker_image:
    name: "{{ docker_app_image }}"
    tag: "{{ docker_app_tag }}"
    source: pull
  tags: docker

- name: Run application container
  community.docker.docker_container:
    name: "{{ docker_app_name }}"
    image: "{{ docker_app_image }}:{{ docker_app_tag }}"
    state: started
    restart_policy: always
    ports:
      - "{{ docker_app_port }}:{{ docker_container_port }}"
  tags: docker

- name: Wait for container to be healthy
  ansible.builtin.uri:
    url: "http://localhost:{{ docker_app_port }}"
    status_code: 200
  retries: 5
  delay: 3
  register: health_check
  until: health_check.status == 200
  tags: docker
```

**`roles/docker/handlers/main.yml`**

```yaml
---
- name: Restart Docker
  ansible.builtin.service:
    name: docker
    state: restarted
```

**Key decisions**

| Decision | Reason |
|---|---|
| Docker's official apt repo with GPG key | Ubuntu equivalent of the yum repo; packages are signature-verified |
| `ansible_distribution_release` fact | Role works on any Ubuntu release (`noble` here) |
| `python3-docker` from apt | `community.docker` modules need the Docker SDK; pip is restricted on Ubuntu 24.04 |
| `docker-compose-plugin` | Modern Compose, replaces pip/binary install |
| `acl` package | Needed for `become_user: deploy` to work |
| `no_log: true` | Keeps credentials out of the output |
| `daemon.json` + handler + `flush_handlers` | Log rotation, and Docker restarts only when the file changes |
| `restart_policy: always` | Container comes back after a reboot |
| `uri` with `retries` | Waits for the container instead of failing instantly |

Collection installed: `ansible-galaxy collection install community.docker`

**Result:** Docker 29.9.1 installed, container `myapp` running with `0.0.0.0:8080->80/tcp`, and `deploy` is in the `docker` group.

![Docker role run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/site.yml%20docker-2.png)
![docker ps](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/docker%20ps.png)

---

## Task 4: `nginx` Role

**`group_vars/web/vars.yml`** (single source of truth for the port)

```yaml
---
docker_app_port: 8080
nginx_upstream_port: "{{ docker_app_port }}"
nginx_http_port: 80
nginx_server_name: "_"
```

**`roles/nginx/defaults/main.yml`**

```yaml
---
nginx_http_port: 80
nginx_upstream_port: 8080
nginx_server_name: "_"
nginx_worker_connections: 768
```

**`roles/nginx/tasks/main.yml`**

```yaml
---
- name: Install Nginx
  ansible.builtin.apt:
    name: nginx
    state: present
    update_cache: true
    cache_valid_time: 3600
  tags: nginx

- name: Remove default Nginx site
  ansible.builtin.file:
    path: /etc/nginx/sites-enabled/default
    state: absent
  notify: Reload Nginx
  tags: nginx

- name: Deploy main Nginx config
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: "0644"
    backup: true
  notify: Reload Nginx
  tags: nginx

- name: Deploy reverse proxy config
  ansible.builtin.template:
    src: app-proxy.conf.j2
    dest: /etc/nginx/conf.d/app-proxy.conf
    owner: root
    group: root
    mode: "0644"
  notify: Reload Nginx
  tags: nginx

- name: Test Nginx configuration
  ansible.builtin.command: nginx -t
  changed_when: false
  tags: nginx

- name: Start and enable Nginx
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: true
  tags: nginx
```

**`roles/nginx/handlers/main.yml`**

```yaml
---
- name: Reload Nginx
  ansible.builtin.service:
    name: nginx
    state: reloaded

- name: Restart Nginx
  ansible.builtin.service:
    name: nginx
    state: restarted
```

**`roles/nginx/templates/nginx.conf.j2`**

```nginx
# Main Nginx config -- Managed by Ansible. Do not edit by hand.
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections {{ nginx_worker_connections }};
}

http {
    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;

    gzip on;

    include /etc/nginx/conf.d/*.conf;
}
```

**`roles/nginx/templates/app-proxy.conf.j2`** (the reverse proxy template)

```nginx
# Reverse Proxy to Docker Container -- Managed by Ansible
upstream docker_app {
    server 127.0.0.1:{{ nginx_upstream_port }};
}

server {
    listen {{ nginx_http_port }};
    server_name {{ nginx_server_name }};

    location / {
        proxy_pass http://docker_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        access_log off;
        default_type text/plain;
        return 200 'OK';
    }

{% if app_env == 'production' %}
    access_log /var/log/nginx/{{ project_name }}_access.log;
    error_log /var/log/nginx/{{ project_name }}_error.log;
{% else %}
    access_log /var/log/nginx/{{ project_name }}_access.log;
    error_log /var/log/nginx/{{ project_name }}_error.log debug;
{% endif %}
}
```

**Key points**

- `nginx -t` runs before any reload, so a bad config fails the play without touching the live site.
- Handlers: all config tasks notify `Reload Nginx`, which runs once at the end of the play and does not drop connections.
- `{% if app_env == 'production' %}` gives quiet logs in production and debug logs in development.
- `server_tokens off` hides the Nginx version.

**Result:** `nginx -t` successful, service `active`, `ss -tlnp` shows nginx on `:80` and docker-proxy on `:8080`.

![Nginx role run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/site.yml%20nginx-1.png)
![Nginx verification](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/nginx%20verification.png)

---

## Task 5: Vault-Encrypted Docker Hub Credentials

```bash
echo "<vault-password>" > .vault_pass
chmod 600 .vault_pass
echo ".vault_pass" >> .gitignore

ansible-vault create group_vars/web/vault.yml
```

Contents of the vault (before encryption):

```yaml
vault_docker_username: adityasondekar
vault_docker_password: <dockerhub-access-token>
```

Encrypted file on disk:

```bash
cat group_vars/web/vault.yml
# $ANSIBLE_VAULT;1.1;AES256
# 6339373636...
```

![Encrypted vault file](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/Vault.png)

**How Vault protected the credentials**

- The username and token are AES256-encrypted at rest, so `vault.yml` is safe to commit.
- `ansible.cfg` points to `.vault_pass`, so Ansible decrypts automatically at runtime without a prompt.
- `.vault_pass` is in `.gitignore` and never committed.
- `no_log: true` on the login task keeps the credentials out of playbook output.
- I used a Docker Hub **access token** (read-only), not my account password, so it can be revoked at any time.
- Secrets are split into `vault.yml` (encrypted) and `vars.yml` (readable), so teammates can still review normal settings in Git.

**Result:** the login task ran as `deploy`, and `/home/deploy/.docker/config.json` exists with `-rw-------` permissions, owned by `deploy`.


---

## Task 6: Master Playbook and Deployment

**`site.yml`**

```yaml
---
- name: Apply common configuration
  hosts: all
  become: true
  roles:
    - common
  tags: common

- name: Install Docker and run containers
  hosts: web
  become: true
  roles:
    - docker
  tags: docker

- name: Configure Nginx reverse proxy
  hosts: web
  become: true
  roles:
    - nginx
  tags: nginx
```

```bash
ansible-playbook site.yml --syntax-check
ansible-playbook site.yml --list-tasks
ansible-playbook site.yml --check --diff     # dry run first, always
ansible-playbook site.yml                    # full deploy
```

![Dry run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/check%20--diff.png)
![Dry run](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/check%20--diff-2.png)
![Full deployment](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/full%20deployment.png)
![Full deployment](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/full%20deployment-1.png)

### Tags for selective deployment

```bash
ansible-playbook site.yml --tags docker        # only Docker and containers
ansible-playbook site.yml --tags nginx         # only Nginx config
ansible-playbook site.yml --skip-tags common   # everything except baseline setup
```

| Command | When I would use it |
|---|---|
| `--tags docker` | Deploying a new image or changing container settings |
| `--tags nginx` | Updating the proxy config without touching Docker |
| `--skip-tags common` | Re-running the app layers when the baseline is already done |

Tags saved time because Ansible runs only the matching tasks instead of the entire playbook.


### Verification

1. **Container directly on 8080:** `curl -I http://<PRIVATE_IP>:8080` returned `200 OK` with `Server: nginx/1.31.7` (the container answering).
2. **Through Nginx on 80:** `curl -I http://<PUBLIC_IP>` returned `200 OK` with `Server: nginx` (no version, so the proxy answered).
3. **Container and port mapping:** `docker ps` showed `myapp` with `0.0.0.0:8080->80/tcp`.
4. **Health endpoint:** `curl http://<PUBLIC_IP>/health` returned `OK`.

![Container direct](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/nginx%20verification.png)
![docker ps](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/docker%20ps.png)

### Bonus demo: the 502 test

Stopping the container made port 80 return `502 Bad Gateway`, while `/health` still returned `OK` (Nginx answers it itself). Starting the container restored `200`. This showed that Nginx and the container are separate layers.

---

## Task 7: Bonus -- Swap the App and Re-run

```bash
# Remove the old container so port 8080 is free
ansible web -b -m community.docker.docker_container -a "name=myapp state=absent"

# Deploy Apache with a new container name
ansible-playbook site.yml --tags docker \
  -e "docker_app_image=httpd docker_app_tag=latest docker_app_name=apache-app"
```

- The container is replaced, and the Nginx config did not change.
- Port 80 still serves traffic, now showing Apache's "It works!" page.
- `-e` extra vars have the highest precedence, so no file edits were needed.

![Apache swap](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/7501e055d3c30581295758c173387c224c0c292e/Day72/Day72-Screenshots/swap%20to%20apache.png)


### Issue I hit and how I debugged it

The health check task failed with `Connection refused` on `localhost:8080` and `changed=0`. That meant nothing was listening on 8080, so the container's real state differed from what Ansible expected. I inspected the server with `docker ps -a`, `docker logs` and `ss -tlnp`, removed the leftover containers with `state: absent`, and re-ran the playbook with the `-e` variables.

**Lesson:** the old container holds the host port, so when changing the container name, remove the old container first. Also, any later run needs the same `-e` variables (or permanent values in `group_vars/web/vars.yml`), otherwise the playbook swaps back to the defaults.

---

## Reflection

### 1. How many total tasks ran?

The playbook has three plays (`common`, `docker`, `nginx`):

| Play | Tasks |
|---|---|
| Gathering Facts (3 plays) | 3 |
| `common` role | 5 |
| `docker` role | 13 (including the `flush_handlers` meta task) |
| `nginx` role | 6 |
| **Total** | **about 27** (confirm with `ansible-playbook site.yml --list-tasks`) |

### 2. Concepts mapped to the days I learned them

| Day | Concept used in this project |
|-----|-------------|
| 68 | Inventory (`inventory.ini`), ad-hoc commands (`ping`, `docker ps`), SSH key setup |
| 69 | Playbooks (`site.yml`), modules (`apt`, `service`, `template`, `docker_container`), handlers (`Reload Nginx`, `Restart Docker`) |
| 70 | Variables (`group_vars`), facts (`ansible_distribution_release`), conditionals (`when`, `{% if %}`), `retries`/`until` |
| 71 | Roles, Jinja2 templates, Galaxy (`ansible-galaxy init`, collections), Vault |
| 72 | Everything combined, plus tags and Terraform for infrastructure |

### 3. What I would add for production

- **SSL with certbot:** HTTPS on 443 with automatic certificate renewal
- **Bind the container to localhost** (`127.0.0.1:8080:80`) so only Nginx can reach it (`ss` showed `0.0.0.0:8080`)
- **Restrict SSH** to my IP only and disable password login
- **Monitoring and alerting:** Prometheus and Grafana, or CloudWatch
- **Log rotation and central logging:** logrotate for Nginx, a log shipper for containers
- **Multi-container Compose** with the `docker-compose.yml.j2` template (app plus database)
- **Pin image tags** (for example `nginx:1.27`) instead of `latest`
- **CI/CD:** run the playbook from a pipeline, with the vault password stored as a pipeline secret
- **Multiple servers and environments:** use `web_count` in Terraform and separate inventories

### 4. Cleanup

```bash
cd ~/72-Day/terraform
terraform destroy
```

I also deleted the Docker Hub access token created for this exercise.



---

## Key Learnings

- Roles keep a project organized: each has one job and can be reused.
- Idempotency is the point of Ansible: re-running should change nothing when nothing needs to change.
- A reverse proxy lets me swap the application behind it without changing the public address.
- Tags and `--check --diff` make deployments safer and faster.
- Vault lets secrets live in the repository without being exposed.
- Terraform builds the infrastructure and Ansible configures it, so together they cover the full path from nothing to a running service.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`