# 🚀 Day 09 – Linux User & Group Management

> **90 Days of DevOps Challenge**

## 📌 Objective

The goal of Day 09 was to learn how Linux manages **users, groups, and permissions** by completing hands-on practical tasks.

By the end of this challenge, I learned how to:

- 👤 Create Linux users
- 🔑 Set user passwords
- 👥 Create and manage groups
- 🔄 Assign users to multiple groups
- 📁 Configure shared directories
- 🔒 Manage group ownership and permissions
- ✅ Verify user and group configurations

---

# 🛠️ Tasks Completed

## ✅ Task 1 – Create Users

Created the following users with home directories:

- tokyo
- berlin
- professor

### Create Users

```bash
sudo useradd -m tokyo
sudo useradd -m berlin
sudo useradd -m professor
```

### Set Passwords

```bash
sudo passwd tokyo
sudo passwd berlin
sudo passwd professor
```

### Verify Users

```bash
cat /etc/passwd | grep -E "tokyo|berlin|professor"
```

Check home directories:

```bash
ls /home
```

---

## ✅ Task 2 – Create Groups

Created two Linux groups:

- developers
- admins

### Commands

```bash
sudo groupadd developers
sudo groupadd admins
```

### Verify

```bash
cat /etc/group | grep -E "developers|admins"
```

---

## ✅ Task 3 – Assign Users to Groups

Assigned users according to the challenge requirements.

| User | Groups |
|-------|---------|
| tokyo | developers |
| berlin | developers, admins |
| professor | admins |

### Commands

```bash
sudo usermod -aG developers tokyo

sudo usermod -aG developers berlin
sudo usermod -aG admins berlin

sudo usermod -aG admins professor
```

### Verify

```bash
groups tokyo
groups berlin
groups professor
```

---

## ✅ Task 4 – Shared Directory

Created a shared directory for the developers group.

### Create Directory

```bash
sudo mkdir -p /opt/dev-project
```

### Change Group Owner

```bash
sudo chgrp developers /opt/dev-project
```

### Set Permissions

```bash
sudo chmod 775 /opt/dev-project
```

### Verify

```bash
ls -ld /opt/dev-project
```

### Test Access

Create files as different users:

```bash
sudo -u tokyo touch /opt/dev-project/tokyo-file.txt

sudo -u berlin touch /opt/dev-project/berlin-file.txt
```

Verify:

```bash
ls -l /opt/dev-project
```

---

## ✅ Task 5 – Team Workspace

Created another collaborative workspace.

### Create User

```bash
sudo useradd -m nairobi
sudo passwd nairobi
```

### Create Group

```bash
sudo groupadd project-team
```

### Add Members

```bash
sudo usermod -aG project-team nairobi
sudo usermod -aG project-team tokyo
```

### Create Workspace

```bash
sudo mkdir -p /opt/team-workspace
```

### Configure Group Ownership

```bash
sudo chgrp project-team /opt/team-workspace
```

### Set Permissions

```bash
sudo chmod 775 /opt/team-workspace
```

### Verify

```bash
ls -ld /opt/team-workspace
```

### Test

```bash
sudo -u nairobi touch /opt/team-workspace/nairobi-file.txt
```

Verify:

```bash
ls -l /opt/team-workspace
```

---

# 📚 Commands Learned

| Command | Description |
|----------|-------------|
| `useradd -m` | Create a new user with a home directory |
| `passwd` | Set or update a user's password |
| `groupadd` | Create a new group |
| `usermod -aG` | Add a user to supplementary groups |
| `groups` | Display a user's group memberships |
| `chgrp` | Change group ownership of a file or directory |
| `chmod` | Modify file or directory permissions |
| `sudo -u` | Execute a command as another user |
| `ls -ld` | Display directory permissions |
| `cat /etc/passwd` | View user information |
| `cat /etc/group` | View group information |

---

# 📖 What I Learned

- Linux uses users and groups to control system access.
- A user can belong to multiple groups.
- Groups simplify permission management for teams.
- Shared directories enable secure collaboration.
- The `775` permission allows:
  - Owner → Read, Write, Execute
  - Group → Read, Write, Execute
  - Others → Read, Execute
- Managing users and permissions is an essential Linux administration and DevOps skill.

---

# 🎯 Key Takeaways

- ✅ Learned Linux user management
- ✅ Practiced group administration
- ✅ Assigned users to multiple groups
- ✅ Configured shared directories
- ✅ Managed group ownership
- ✅ Applied Linux permissions in a real-world scenario

---

## 📸 Output

> Add your screenshots here.

Example:

```
images/
├── create-users.png
├── create-groups.png
├── assign-groups.png
├── shared-directory.png
├── workspace.png
```

---

## 🏆 Day 09 Status

**✅ Challenge Completed**

User & Group Management is a fundamental Linux administration skill that plays a critical role in DevOps, cloud environments, and server management.

---

### 🔗 Connect with Me

- **GitHub:** https://github.com/Workwithaditya01
- **LinkedIn:** *(Add your LinkedIn profile here)*

---

**#90DaysOfDevOps 🚀**
