# Day 09 – Linux User & Group Management Challenge

## Task 1: Create Users

### Create Users with Home Directories

```bash
sudo useradd -m tokyo
sudo useradd -m berlin
sudo useradd -m professor
```

### Set password 

```bash
set passwd tokyo
set passwd berlin
set passwd professor
```

### Verify Users:

#### Check user entries:

```bash
cat /etc/passwd | grep -E "tokyo|berlin|professor"
```

#### Check home directories:

```bash
ls /home
```
---

## Task 2: Create Groups

### Create groups

```bash
sudo groupadd developers
sudo groupadd admins
```

### Verify Groups

```bash
cat /etc/groups | grep -E "developer|admins"
```

---

## Task 3: Assign Users to Groups

### Add user to Groups 

```bash
sudo usermod -aG developers tokyo

sudo usermod -aG developers berlin

sudo usermod -aG admins berlin

sudo usermod -aG admins professor
```

### Verify Membership 

```bash
groups tokyo

groups berlin

groups professor
```
---

## Task 4: Shared Directory

### Create Directoyr

```bash
sudo mkdir -p /opt/dev-project
```

### Change Group Owner 

```bash
sudo chgrp developers /opt/dev-project/
```

### Set Permission

```bash
sudo chmod 775 /opt/dev-project/
```

### Verify Permission

```bash
ls -ld /opt/dev-project
```

### Test as Tokyo

```bash
sudo -u tokyo touch /opt/dev-project/testfile1.txt
```

### Test as berlin

```bash
sudo -u berlin touch /opt/dev-project/testfile2.txt
```

### verify Files

```bash
ls -l /opt/dev-project
```

---

## Task 5: Team Workspace

### Create user

```bash
sudo useradd -m nairobi
```
### Create password

```bash
sudo passwd nairobi
```

### Add members

```bash
sudo usermod -aG project-team tokyo
sudo usermod -aG project-team nairobi 
```

### Create Workspace Directory

```bash
sudo mkdir -p /opt/team-workspace
```

### Set Group Owner

```bash
sudo chgrp project-team /opt/team-workspace
```

### Set Permission

```bash
sudo chmod 775 /opt/team-workspace
```

### Verify

```bash
ls -ld /opt/team-workspace
```

### Test File creation 

```bash
sudo -u nairobi touch /opt/team-workspace/nairobi-file.txt
```

### Check result

```bash
ls -l /opt/team-workspace
```
--- 

## Command Learned

| Command | Purpose |
|---------|---------|
| useradd -m	| Create user with home directory |
| passwd | Set user password |
| groupadd | Create group |
| usermod -aG | Add user to supplementary group |
| groups | Show user group memberships |
| chgrp	| Change group ownership |
| chmod | Change permissions |
| sudo -u | Run command as another user |
| ls -ld | View directory permissions |
|--------|----------------------------|

---




