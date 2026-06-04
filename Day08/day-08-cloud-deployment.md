# Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

## Part 1: Launch EC2 Instance & SSH AccessPart 1: Launch EC2 Instance & SSH Access

### EC2 Configuration

| Settings | Value | 
|----------|-------|
| AMI | Ubuntu Server 22.04 LTS |
| instance Type | t3.micro | 
| Key pair | Allready Existed | 
| Security Group | SSH(22), HTTP(80) |


### Connection via SSH

```text
ssh -i "Practics-Ec2-server-key.pem" ubuntu@ec2-13-233-56-210.ap-south-1.compute.amazonaws.com
```
----

## Part 2: Install Nginx

### Update System

```bash
sudo apt update
sudo apt upgrade-y
```

### Install Nginx

```bash
sudo apt install nginx -y
```

### Verify Installation

```bash
nginx -v
```

### Check Nginx Status

```bash
sudo systemctl status nginx
```

### Enable Nginx at Boot

```bash
sudo systemctl enable nginx
```
----

## Part 3: Configure Security Group

```text
Nginx listens on Port 80 by default.

To allow public access, add the following inbound rule:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| HTTP | TCP | 80 | 0.0.0.0/0 |
```

## Verify Public Access 

```text
Open a browser and visit:

http://<PUBLIC-IP>

You should see:

Welcome to nginx!
```
----

## Part 4: Working With Nginx Logs

---

### view Access Logs

#### Command

```bash
sudo tail -20 /var/log/nginx/access.log
```
#### Output

```text
223.236.99.65 - - [04/Jun/2026:04:54:40 +0000] "GET /favicon.ico HTTP/1.1" 404 197 "http://13.233.56.210/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36"
91.218.66.198 - - [04/Jun/2026:04:55:35 +0000] "CONNECT 37.84.164.83:10000 HTTP/1.1" 400 0 "-" "-"
91.218.66.198 - - [04/Jun/2026:04:55:40 +0000] "CONNECT 37.84.164.83:10000 HTTP/1.1" 400 0 "-" "-"
91.218.66.198 - - [04/Jun/2026:04:55:46 +0000] "CONNECT 37.84.164.83:10000 HTTP/1.1" 400 166 "-" "-"
91.218.66.198 - - [04/Jun/2026:04:55:47 +0000] "CONNECT 37.84.164.83:10000 HTTP/1.1" 400 0 "-" "-"
216.180.246.186 - - [04/Jun/2026:05:08:09 +0000] "GET / HTTP/1.0" 200 615 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:09:14 +0000] "GET / HTTP/1.0" 200 615 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:10:02 +0000] "\x16\x03\x01\x00\xFD\x01\x00\x00\xF9\x03\x03\xFD\xBA\xD4\x1B\xC6(\x17+\xEB\x9F\xD3\xC8\xD2\x15\x05\x00\x9A\xF3vG\xE4#" 400 166 "-" "-"
216.180.246.186 - - [04/Jun/2026:05:10:57 +0000] "GET / HTTP/1.1" 200 409 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:10:57 +0000] "GET /manage/account/login HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:10:58 +0000] "GET /admin/index.html HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:01 +0000] "GET /index.html HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:02 +0000] "GET /+CSCOE+/logon.html HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:04 +0000] "GET /cgi-bin/login.cgi HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:06 +0000] "GET /login.htm HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:08 +0000] "GET /login.html HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:10 +0000] "GET /login.jsp HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:12 +0000] "GET /login HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:13 +0000] "GET /doc/index.html HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler)"
216.180.246.186 - - [04/Jun/2026:05:11:15 +0000] "GET /remote/login HTTP/1.1" 404 134 "-" "Mozilla/5.0 (compatible; GenomeCrawlerd/1.0; +https://www.nokia.com/genomecrawler
```
----

### View Error Logs

#### Command

```bash
sudo tail -20 /var/log/nginx/error.log
```

#### Output 

```text
2026/06/04 04:45:59 [notice] 16900#16900: using inherited sockets from "5;6;"
```

### Save Logs to a File

```bash
sudo cat /var/log/nginx/access.log > ~/nginx-logs.txt
```
----

### Download Logs to Local Machine

#### Command

```bash
scp -i your-key.pem ubuntu@<PUBLIC-IP>:~/nginx-logs.txt .
```

#### Explaination of Command

```text
What is scp?

scp stands for Secure Copy Protocol.

It is used to securely transfer files between:

Your local machine ↔ Remote server
Remote server ↔ Another remote server

It uses SSH (Port 22) underneath, which means the transfer is encrypted.
```
---

```bash
scp
```

```text
The command used for copying files securely.
```

```bash
-i your-key.pem
```

```text
Specifies the SSH private key to authenticate with the EC2 instance.
Without the correct key, AWS won't allow access to the server.
```

```bash
ubuntu@13.233.56.210
```

```text
This tells SCP:

- Username = ubuntu
- Server IP = 13.233.56.210

It's the same format used when connecting with SSH
```

```bash
:~/nginx-logs.txt
```

```text
This is the source file on the EC2 instance
```

----


### Additional Verification Commands

#### Command

```bash
ps aux | grep nginx
```

#### Output

```text
root       16900  0.0  1.0  14828  9332 ?        S    04:45   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data   16903  0.0  0.6  16624  5708 ?        S    04:45   0:00 nginx: worker process
www-data   16904  0.0  0.5  16624  5328 ?        S    04:45   0:00 nginx: worker process
ubuntu     17408  0.0  0.2   7144  2340 pts/0    S+   05:28   0:00 grep --color=auto nginx
```

### Check Listening Ports

#### Command

```bash
sudo ss -tulpn | grep :80
```

#### Output

```text
tcp   LISTEN 0      511              0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=16904,fd=5),("nginx",pid=16903,fd=5),("nginx",pid=16900,fd=5))
tcp   LISTEN 0      511                 [::]:80           [::]:*    users:(("nginx",pid=16904,fd=6),("nginx",pid=16903,fd=6),("nginx",pid=16900,fd=6))
```

# Key Takeaway

```text
Deploying Nginx on AWS EC2 provided hands-on experience with real-world DevOps tasks including cloud provisioning, remote server
management, network security, service monitoring, troubleshooting, and log management. These are core skills used daily by DevOps
`and Cloud Engineers in production environments.
```
