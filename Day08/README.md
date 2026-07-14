# Day 08 – Deploying Nginx on AWS EC2

> **90 Days of DevOps Challenge**

## 📖 Overview

On Day 08 of my **#90DaysOfDevOps** challenge, I deployed a real web server on an **AWS EC2** instance and learned the fundamentals of cloud server management.

This hands-on exercise covered launching an EC2 instance, connecting securely using SSH, installing and managing Nginx, configuring AWS Security Groups, understanding networking concepts such as ports, and working with server logs.

These are practical skills that DevOps Engineers use daily when managing production servers.

---

# 🎯 Objectives

- Launch an AWS EC2 instance
- Connect to the server using SSH
- Update the Linux system
- Install and configure Nginx
- Verify the Nginx service
- Configure Security Groups to allow HTTP traffic
- Access the web server from the internet
- View and extract Nginx logs
- Download log files using SCP
- Understand ports and basic cloud networking

---

# 🏗️ Architecture

```text
                 Internet
                     │
                     │ HTTP (Port 80)
                     ▼
            ┌──────────────────┐
            │   AWS EC2 Server │
            │ Ubuntu + Nginx   │
            └────────┬─────────┘
                     ▲
                     │
              SSH (Port 22)
                     │
             Local Development PC
```

---

# ☁️ Step 1: Launch an AWS EC2 Instance

### EC2 Configuration

| Setting | Value |
|----------|-------|
| Cloud Provider | AWS |
| Operating System | Ubuntu Server 22.04 LTS |
| Instance Type | t2.micro |
| Authentication | SSH Key Pair |
| Security Group | SSH (22), HTTP (80) |

---

# 🔐 Step 2: Connect to the Instance via SSH

Change the permission of the private key:

```bash
chmod 400 your-key.pem
```

Connect to the EC2 instance:

```bash
ssh -i your-key.pem ubuntu@<PUBLIC-IP>
```

Verify the connection:

```bash
whoami
hostname
```

---

# 📦 Step 3: Update the Server

Update package information:

```bash
sudo apt update
```

Upgrade installed packages:

```bash
sudo apt upgrade -y
```

Keeping the system updated ensures that the latest security patches and software versions are installed.

---

# 🌐 Step 4: Install Nginx

Install Nginx:

```bash
sudo apt install nginx -y
```

Verify the installation:

```bash
nginx -v
```

Example:

```text
nginx version: nginx/1.18.x
```

---

# 🚀 Step 5: Verify Nginx Service

Check service status:

```bash
sudo systemctl status nginx
```

Verify that it is active:

```bash
sudo systemctl is-active nginx
```

Expected output:

```text
active
```

Enable Nginx to start automatically after reboot:

```bash
sudo systemctl enable nginx
```

---

# 🔥 Step 6: Configure AWS Security Group

To make the website accessible from the internet, add the following inbound rule:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| HTTP | TCP | 80 | 0.0.0.0/0 |

The existing SSH rule remains:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | My Public IP |

---

# 🌍 Step 7: Verify Public Access

Open your browser and visit:

```text
http://<PUBLIC-IP>
```

If everything is configured correctly, the default Nginx welcome page will be displayed.

---

# 📄 Step 8: View Nginx Logs

View recent access logs:

```bash
sudo tail -20 /var/log/nginx/access.log
```

View recent error logs:

```bash
sudo tail -20 /var/log/nginx/error.log
```

---

# 💾 Step 9: Save Logs to a File

Create a copy of the access log:

```bash
sudo cat /var/log/nginx/access.log > ~/nginx-logs.txt
```

Verify:

```bash
ls -lh ~/nginx-logs.txt
```

---

# 📥 Step 10: Download the Log File

Run the following command from your **local machine**:

```bash
scp -i your-key.pem ubuntu@<PUBLIC-IP>:~/nginx-logs.txt .
```

This securely downloads the log file from the EC2 instance to your current local directory.

---

# 🔍 Additional Verification Commands

Check running Nginx processes:

```bash
ps aux | grep nginx
```

Check whether Nginx is listening on Port 80:

```bash
sudo ss -tulpn | grep :80
```

Test the web server locally:

```bash
curl localhost
```

---

# 🌐 Understanding Ports

## Port 22 (SSH)

Port **22** is used for **Secure Shell (SSH)**.

It allows secure remote access to the EC2 instance for server administration.

Example:

```bash
ssh -i your-key.pem ubuntu@<PUBLIC-IP>
```

---

## Port 80 (HTTP)

Port **80** is the default port used by **HTTP**.

Nginx listens on Port 80 to serve web pages to users over the internet.

Without allowing Port 80 in the Security Group, the website cannot be accessed externally.

---

# 🛡️ AWS Security Groups

A Security Group acts as a virtual firewall for an EC2 instance.

It controls which incoming and outgoing network traffic is allowed.

For this project:

| Port | Purpose |
|------|----------|
| 22 | SSH Remote Access |
| 80 | HTTP Web Traffic |

All other ports remain blocked unless explicitly allowed.

---

# 📚 Learning Outcomes

By completing Day 08, I learned:

- How to launch and configure an AWS EC2 instance
- How to securely connect using SSH
- How to install and manage Nginx
- How AWS Security Groups protect cloud resources
- The purpose of Port 22 and Port 80
- How web traffic reaches a server
- How to monitor Nginx using log files
- How to securely transfer files using SCP
- Basic troubleshooting techniques for cloud servers

---

# 📋 Commands Summary

```bash
chmod 400 your-key.pem

ssh -i your-key.pem ubuntu@<PUBLIC-IP>

sudo apt update
sudo apt upgrade -y

sudo apt install nginx -y

nginx -v

sudo systemctl status nginx
sudo systemctl is-active nginx
sudo systemctl enable nginx

sudo tail -20 /var/log/nginx/access.log
sudo tail -20 /var/log/nginx/error.log

sudo cat /var/log/nginx/access.log > ~/nginx-logs.txt

scp -i your-key.pem ubuntu@<PUBLIC-IP>:~/nginx-logs.txt .

sudo ss -tulpn | grep :80

curl localhost
```

---

# 📁 Project Structure

```text
Day08/
├── README.md
└── nginx-logs.txt
```

---

# 💡 Key Takeaways

- AWS EC2 provides virtual machines in the cloud.
- SSH enables secure remote server management.
- Nginx is a lightweight and high-performance web server.
- Security Groups function as a firewall for EC2 instances.
- Port 22 is used for SSH, while Port 80 is used for HTTP.
- Server logs are essential for monitoring and troubleshooting.
- SCP provides a secure way to transfer files between local and remote systems.

---

# ✅ Conclusion

Day 08 introduced practical cloud server management by deploying a real Nginx web server on AWS EC2. Through this exercise, I gained hands-on experience with cloud provisioning, Linux administration, networking, security groups, web server configuration, log management, and secure file transfer—skills that are fundamental for DevOps and Cloud Engineering roles.

---

**#90DaysOfDevOps 🚀**
