# Day 07 – Linux File System Hierarchy & Scenario-Based Practice

## 1. [ / ] (Root Directory)

### Purpose:

```text
- the top-level directory of Linux.
- Every file and folder starts from here.
```

### Command:

```bash
ls -l /
```

### Common Items Seen:

```text
drwxr-xr-x   5 root root  4096 Apr 21 05:24 boot
drwxr-xr-x  16 root root  3420 Jun  4 03:42 dev
drwxr-xr-x 108 root root  4096 Jun  4 03:42 etc
drwxr-xr-x   3 root root  4096 Jun  4 03:42 home
```

### I would use this when

```text
I need to navigate the entire Linux file system from the starting point.
```

---

## 2. /home

### Purpose:

```text
- Stores personal files and directories for normal users.
- Each user gets a separate home folder.
```

### Command:

```bash
ls -l /home
```

### Common Items Seen:

```text
drwxr-x--- 4 ubuntu ubuntu 4096 Jun  4 03:42 ubuntu
```

### I would use this when

```text
I need to access user files, scripts, downloads, or projects
```

---

## 3. /root

### Purpose:

```text
- Home directory of the root (administrator) user.
- Separate from regular users
```

### Command:

```bash
sudo ls -l /root
```

### Common Items Seen:

```text
drwx------ 3 root root 4096 Jun  4 03:42 snap
```

### I would use this when

```text
Working with administrative configurations or root-owned files.
```

---

## 4. /etc

### Purpose:

```text
- Stores system-wide configuration files.
- Important for services and applications
```

### Command:

```bash
ls -l /etc
```

### Common Items Seen:

```text
drwxr-xr-x 5 root root       4096 Apr 21 05:19 ModemManager
drwxr-xr-x 2 root root       4096 Apr 21 05:20 PackageKit
drwxr-xr-x 4 root root       4096 Apr 21 05:18 X11
drwxr-xr-x 4 root root       4096 Apr 21 05:24 acpi
-rw-r--r-- 1 root root       4027 Nov  4  2025 adduser.conf
drwxr-xr-x 2 root root       4096 Apr 21 05:21 alternatives
```

### I Would use this when:

```text
Configuring services such as SSH, networking, or system settings.
```

---

## 5. /var/log

### Purpose:

```text
Contains system and application log files.
Critical for troubleshooting.
```

### Command:

```bash
ls -l /var/log
```

### Common Items Seen:

```text
lrwxrwxrwx 1 root      root                39 Apr 21 05:18 README -> ../../usr/share/doc/systemd/README.logs
-rw-r--r-- 1 root      root               736 Apr 21 05:21 alternatives.log
drwx------ 3 root      root              4096 Jun  4 03:42 amazon
-rw-r----- 1 root      adm                  0 Jun  4 03:42 apport.log
drwxr-xr-x 2 root      root              4096 Apr 21 05:25 apt
```

### I Would use this when:

```text
Investigating errors, service failures, or authentication issues.
```

---

## 6. /tmp

### Purpose:

```text
- Stores temporary files created by users and applications.
- Usually cleared automatically.
```

### Command:

```bash
ls -l /tmp
```

### Common Items Seen:

```text
drwx------ 2 root root 40 Jun  4 03:42 snap-private-tmp
drwx------ 3 root root 60 Jun  4 03:42 systemd-private-255453c4f85c4710a95dc139ebd3dc0e-ModemManager.service-GlY0OE
drwx------ 3 root root 60 Jun  4 03:42 systemd-private-255453c4f85c4710a95dc139ebd3dc0e-chrony.service-aUgM9M
drwx------ 3 root root 60 Jun  4 03:42 systemd-private-255453c4f85c4710a95dc139ebd3dc0e-irqbalance.service-VwCWMf
drwx------ 3 root root 60 Jun  4 03:42 systemd-private-255453c4f85c4710a95dc139ebd3dc0e-polkit.service-WpRpHh
drwx------ 3 root root 60 Jun  4 03:42 systemd-private-255453c4f85c4710a95dc139ebd3dc0e-systemd-logind.service-HHbnbg
```

### I Would use this when:

```text
Checking temporary data or testing file operations.
```

---


## 7. /bin

### Purpose:

```text
Contains essential command binaries required for system operation
```

### Command:

```bash
ls -l /bin
```

### Common Items Seen:

```text
lrwxrwxrwx 1 root root 7 Apr 20 08:46 /bin -> usr/bin
```

### I Would use this when:

```text
Running basic Linux commands required for everyday administration.
```

---

## 8. /usr/bin

### Purpose:

```text
Contains most user-accessible command binaries and applications.
```

### Command:

```bash
ls -l /usr/bin
```

### Common Items Seen:

```text
-rwxr-xr-x   1 root root      709512 Feb  5 09:55  3cpio
-rwxr-xr-x   1 root root      133768 Mar  4 21:48  VGAuthService
lrwxrwxrwx   1 root root          28 Mar 30 16:50  '[' -> '../lib/cargo/bin/coreutils/['
-rwxr-xr-x   1 root root       14720 Apr  8 17:26  aa-enabled
-rwxr-xr-x   1 root root       14720 Apr  8 17:26  aa-exec
```

### I Would use this when:

```text
Locating installed software and executable commands
```

---

## 9. /opt

### Purpose:

```text
Stores optional or third-party software packages.
```

### Command:

```bash
ls -l /opt
```

### Common Items Seen:

```text
- Vendor applications
- Custom software installations
```

### I Would use this when:

```text
Managing software installed outside the default package repositories.
```

---

# Part 2 – Troubleshooting Scenarios

## Scenario 1: SSH Login Fails

### Step 1: Check SSH Service

```bash
sudo systemctl status ssh
```

### Step 2: Reviem Logs

```bash
sudo tail -50 /var/log/auth.log
```

### Step 3: Verfiy ssh Configuration

```bash
sudo nano /etc/ssh/sshd_config
```

### Step 4: Restart Service

```bash
sudo systemctl restart ssh
```
---

## Scenario 2: Disk Space Suddenly Full

### Step 1: Check Disk Usage

```bash
df -h
```

### Step 2: Find Large Directories

```bash
du -sh /*
```

### Step 3: Check Logs

```bash
du -sh /var/log/*
```

### Step 4: Remove Temporary Files

```bash
sudo rm -rf /tmp/*
```

--- 

## Scenario 3: Command Not Found Error

### Step 1: Verify Command Location

```bash
which git
```

### Step 2: Check binary Directories

```bash
ls /bin
ls /usr/bin
```

### Step 3: Install Missing Package

```bash
sudo apt install git
```

## Key Takeaways

```text
- / is the starting point of the Linux file system.
- /home stores user data.
- /root belongs to the administrator.
- /etc contains configuration files.
- /var/log is the first place to look when troubleshooting.
- /tmp stores temporary files.
- /bin and /usr/bin contain executable commands.
- /opt is commonly used for third-party software.
- Understanding the Linux file hierarchy makes troubleshooting much faster and more effective
```
