# Ansible Project: Automated Docker + Nginx Deployment

Part of the **#90DaysOfDevOps** challenge (Day 72).

One command takes a fresh Ubuntu server to a running, production-style setup: **Docker** runs the app container, **Nginx** acts as a reverse proxy on port 80, and **Ansible Vault** protects the Docker Hub credentials. Everything is organized as reusable Ansible roles, and the infrastructure is created with Terraform.

```bash
ansible-playbook site.yml
```

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

| Layer | Tool | Role in the project |
|---|---|---|
| Infrastructure | Terraform | Creates the EC2 managed node and security group |
| Configuration | Ansible | Configures the server over SSH |
| Application | Docker | Runs the app in an isolated container |
| Front door | Nginx | Public entry point on port 80, proxies to the container |
| Secrets | Ansible Vault | Encrypts Docker Hub credentials |

## What it does

- **`common` role:** updates the apt cache, installs baseline packages, sets the hostname and timezone, and creates a `deploy` user.
- **`docker` role:** adds Docker's official apt repository, installs Docker CE and the Compose plugin, configures log rotation, logs in to Docker Hub with vault-encrypted credentials, pulls the image, runs the container with `restart_policy: always`, and health-checks it.
- **`nginx` role:** installs Nginx, removes the default site, deploys the main config and the reverse proxy config from Jinja2 templates, validates with `nginx -t`, and reloads through a handler.

## Prerequisites

- A control node (Ubuntu) with **Ansible** and **Terraform** installed
- AWS credentials (an IAM role on the control node, or `aws configure`)
- A managed node running **Ubuntu 24.04** reachable over SSH (created by Terraform in this project)
- A Docker Hub account and a **read-only access token**
- Ansible collections:

```bash
ansible-galaxy collection install community.docker community.general
```

## Project structure

```
ansible-docker-project/
  ansible.cfg
  inventory.ini
  site.yml                          # Master playbook
  .gitignore
  group_vars/
    all.yml                         # Common variables
    web/
      vars.yml                      # Docker/Nginx port variables
      vault.yml                     # Encrypted Docker Hub credentials
  roles/
    common/
      tasks/main.yml
    docker/
      tasks/main.yml
      handlers/main.yml
      defaults/main.yml
      templates/docker-compose.yml.j2   # reserved for a multi-container extension
    nginx/
      tasks/main.yml
      handlers/main.yml
      defaults/main.yml
      templates/
        nginx.conf.j2
        app-proxy.conf.j2
```

## Getting started

### 1. Create the server (Terraform)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

The security group allows SSH (22), HTTP (80), and 8080 from the control node only. Note the public IP from `terraform output`.

### 2. Configure Ansible

`ansible.cfg`:

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
remote_user = ubuntu
private_key_file = ~/.ssh/ansible-practice-key.pem
vault_password_file = .vault_pass
```

`inventory.ini`:

```ini
[web]
web-1 ansible_host=<PUBLIC_IP>

[web:vars]
ansible_python_interpreter=/usr/bin/python3
```

Test connectivity:

```bash
ansible all -m ping
```

### 3. Set up Vault

```bash
echo "<your-vault-password>" > .vault_pass
chmod 600 .vault_pass
ansible-vault create group_vars/web/vault.yml
```

Add your credentials inside the editor:

```yaml
vault_docker_username: <dockerhub-username>
vault_docker_password: <dockerhub-access-token>
```

`.vault_pass` is listed in `.gitignore` and must never be committed. `vault.yml` is encrypted (AES256), so it is safe to commit.

### 4. Deploy

```bash
ansible-playbook site.yml --check --diff    # dry run first
ansible-playbook site.yml                   # full deploy
```

## Usage

### Run only part of the stack with tags

```bash
ansible-playbook site.yml --tags docker        # Docker and containers only
ansible-playbook site.yml --tags nginx         # Nginx config only
ansible-playbook site.yml --skip-tags common   # skip baseline setup
```

### Deploy a different application

Variables passed with `-e` override everything else:

```bash
# Free the port by removing the old container
ansible web -b -m community.docker.docker_container -a "name=myapp state=absent"

# Deploy Apache
ansible-playbook site.yml --tags docker \
  -e "docker_app_image=httpd docker_app_tag=latest docker_app_name=apache-app"
```

Nginx keeps proxying on port 80 with no config change. To make the change permanent, set `docker_app_image` and `docker_app_name` in `group_vars/web/vars.yml`. Without them, later runs go back to the defaults (`nginx` image, `myapp` name).

### Key variables

| Variable | Default | Where |
|---|---|---|
| `docker_app_image` | `nginx` | `roles/docker/defaults/main.yml` |
| `docker_app_tag` | `latest` | `roles/docker/defaults/main.yml` |
| `docker_app_name` | `myapp` | `roles/docker/defaults/main.yml` |
| `docker_app_port` | `8080` | `group_vars/web/vars.yml` |
| `nginx_upstream_port` | `{{ docker_app_port }}` | `group_vars/web/vars.yml` |
| `nginx_http_port` | `80` | `group_vars/web/vars.yml` |
| `app_env` | `development` | `group_vars/all.yml` (`production` turns off debug logging) |
| `timezone` | `Asia/Kolkata` | `group_vars/all.yml` |

## Verify the deployment

```bash
# Container directly on 8080 (use the managed node's private IP)
curl -I http://<PRIVATE_IP>:8080

# Through Nginx on port 80
curl -I http://<PUBLIC_IP>

# Nginx health endpoint
curl http://<PUBLIC_IP>/health

# Container and port mapping
ansible web -b -a "docker ps"
```

Expected results:

- Port 8080 returns `200 OK` from the container itself.
- Port 80 returns `200 OK` with `Server: nginx`, which shows the proxy answered.
- `/health` returns `OK`, answered by Nginx itself.
- `docker ps` shows the container with `0.0.0.0:8080->80/tcp`.

Running `ansible-playbook site.yml` a second time should show `changed=0` (or close to it), which proves the setup is **idempotent**.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Connection refused` on the health check | Container not running, or port not published | `ansible web -b -a "docker ps -a"` and `docker logs <name>`, then recreate the container |
| `port is already allocated` after changing the image | The old container still holds port 8080 | Remove it with `state=absent` first |
| `502 Bad Gateway` on port 80 | Nginx is up but the container is down | Start the container and check `docker ps` |
| `Attempting to decrypt but no vault secrets found` | `vault_password_file` missing from `ansible.cfg`, or wrong directory | Run commands from the project root |
| `Decryption failed` | `.vault_pass` does not match the vault password | Fix the password in `.vault_pass` |
| `curl` to port 8080 times out | Security group does not allow your source | Allow 8080 from the control node's private IP |
| `dpkg lock` error | A fresh server is still running apt updates | Wait a minute and rerun |

## Security notes

- Never commit `.vault_pass`, `*.pem`, `.terraform/`, or `terraform.tfstate*`.
- Use a **read-only Docker Hub access token**, not your password, and delete it when finished.
- `no_log: true` keeps credentials out of playbook output.
- This demo opens SSH to `0.0.0.0/0`. Restrict it to your IP in real environments.

## Ideas for production

- HTTPS with certbot and automatic certificate renewal
- Bind the container to localhost (`127.0.0.1:8080:80`) so only Nginx can reach it
- Monitoring and alerting (Prometheus and Grafana, or CloudWatch)
- Log rotation and central logging
- Multi-container Docker Compose using `docker-compose.yml.j2`
- Pinned image tags instead of `latest`
- CI/CD pipeline running the playbook, with the vault password stored as a secret
- Multiple servers and environments through Terraform's `web_count` and separate inventories

## Cleanup

```bash
cd terraform
terraform destroy
```

Also delete the Docker Hub access token created for this project.

## Full write-up

See [`day-72-ansible-project.md`](./day-72-ansible-project.md) for the complete walkthrough: every role's tasks, templates, screenshots, the debugging notes, and the reflection answers.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
