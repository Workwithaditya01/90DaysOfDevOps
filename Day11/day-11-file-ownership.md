# Day 11 challenge:  File Ownership Challenge (chown & chgrp)

## Files & Directories Created

```code
touch devops-file.txt
touch team-notes.txt
touch project-config.yaml
mkdir app-logs/

mkdir -p heist-project/vault
mkdir -p heist-project/planstouch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf
touch heist-project/vault/gold.txt

mkdir bank-heist
touch bank-heist/access-code.txt
touch bank-heist/blueprint.pdf
touch bank-heist/escape-plan.pdf

cd bank-heist/
```
---

## Ownership Changes

### devops-file.txt:

```text
devops-file.txt: ubuntu:ubuntu -> tokyo:ubuntu
```

```text
devops-file.txt: tokyo:ubuntu -> berlin:ubuntu
```

### team-notes.txt

```text
team-notes.txt: ubuntu:ubuntu -> ubuntu:heist-team
```

### project-config.yaml

```text
project-config.yaml: ubuntu:ubunt -> professor:heist-team
```

### app-logs/

```text
app-logs/: ubuntu:ubuntu -> berlin:heist-team
```

### heist-project/

```text
app-logs/: ubuntu:ubuntu -> professor:planners
```

### access-code.txt

```text
access-code.txt: ubuntu:ubuntu -> tokyo:vault-team
```

### blueprint.pdf

```text
blueprint.pdf: ubuntu:ubuntu -> berlin:tech-team
```

### escape-plan.pdf

```text
escape-plan.pdf: ubuntu:ubuntu -> nairobi:vault-team
```

---

## Commands Used

### Files and Directories Created:

```commands
touch devops-file.txt
touch team-notes.txt
touch project-config.yaml
---
mkdir app-logs
mkdir -p heist-project/vault
mkdir -p heist-project/plans
---
touch bank-heist/access-code.txt
touch bank-heist/blueprint.pdf
touch bank-heist/escape-plan.pdf
```

### Adding & Changing Owners and groups:

#### Adding User and groups:

```commands
sudo useradd tokyo
sudo useradd berlin
sudo useradd professor
sudo useradd nairobi

sudo groupadd heist-team
sudo groupadd planners
sudo groupadd vault-team
sudo groupadd tech-team
```

#### Changing Owners and groups:

```commands
sudo chown tokyo devops-file.txt
sudo chown berlin devops-file.txt
sudo chown professor:heist-team project-config.yaml
sudo chown berlin:heist-team app-logs
sudo chown professor:planners heist-project/
sudo chown tokyo:vault-team access-code.txt
sudo chowm berlin:tech-team blueprint.txt
sudo chown nairobi:vault-tam escape-plan.txt
sudo chgrp heist-team team-notes.txt
```

---

## What I learned

- Today I have learned about adding users and groups
- How to change ownership and groups 
- How Different users have different permission for a praticular file

--- 
