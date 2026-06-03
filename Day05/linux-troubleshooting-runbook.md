# Day 05 – Linux Troubleshooting Drill: CPU, Memory, and Logs

## Environment Basics

### 1.Command:

```bash
uname -a 
```
```text
uname stands for Unix Name.

It retrieves information directly from the Linux kernel.

The -a flag means all available information.
```

#### Output:

```text
Linux ip-172-31-32-178 7.0.0-1004-aws #4-Ubuntu SMP PREEMPT Mon Apr 13 13:14:24 UTC 2026 x86_64 GNU/Linux
```

### 2.Command:

```bash
cat /etc/os-release

```

```text
Displays Linux distribution information.
```

#### Output:

```text
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04 (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
LOGO=ubuntu-logo
```
## Filesystem Sanity

### 3.Command:

```bash
mkdir /tmp/runbook-demo
```

```text
Creates a directory
```
#### Output:

```text
Temporary directory created successfully.
Filesystem is writable.
```

### 4.Command:

```bash
cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo
```

```text
Copies a file.
```

#### Output:

```text
total 4
-rw-r--r-- 1 ubuntu ubuntu 221 Jun  3 04:03 hosts-copy
```

## CPU $ Memory

### 5.Command:

```bash
systemctl status ssh
```

```text
Checks status of a service.
```

### Output:

```text
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/usr/lib/systemd/system/ssh.service; disabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/ssh.service.d
             └─ec2-instance-connect.conf
     Active: active (running) since Wed 2026-06-03 03:52:06 UTC; 13min ago
 Invocation: e5ff2c5547374e1fb24b3fc60657d097
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 1016 (sshd)
      Tasks: 1 (limit: 627)
     Memory: 7.1M (peak: 15.2M)
        CPU: 634ms
     CGroup: /system.slice/ssh.service
             └─1016 "sshd: /usr/sbin/sshd -D -o AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys %u %f -o AuthorizedKeysCommandU>

Jun 03 03:57:15 ip-172-31-32-178 sshd-session[1311]: Received disconnect from 78.111.67.242 port 46224:11: disconnected by user [preauth]
Jun 03 03:57:15 ip-172-31-32-178 sshd-session[1311]: Disconnected from authenticating user root 78.111.67.242 port 46224 [preauth]
Jun 03 04:00:38 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:awqEyzxYerj5vs>
Jun 03 04:00:38 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:A14iaMcufzEJVV>
Jun 03 04:00:38 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:SuY/13Y+1oQuHx>
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:/Nul8vqpxP+bcG>
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:71IJnFiB+sCbAp>
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: Received disconnect from 87.121.69.138 port 27986:11: disconnected by user [preauth]
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: Disconnected from authenticating user root 87.121.69.138 port 27986 [preauth]
Jun 03 04:00:47 ip-172-31-32-178 sshd-session[1483]: Connection closed by 68.183.87.42 port 44158 [preauth]
lines 1-26/26 (END)
```

### 6.Command:

```bash
free -h
```

```text
Displays RAM usage.
```

### Output:

```text
               total        used        free      shared  buff/cache   available
Mem:           908Mi       307Mi       386Mi       2.7Mi       324Mi       601Mi
```

## Disk & IO

### 7.Command:

```bash
df -h
```

```text
Displays filesystem usage.
```

### Output:

```text
Filesystem       Size  Used Avail Use% Mounted on
/dev/root        6.7G  2.1G  4.6G  31% /
tmpfs            455M     0  455M   0% /dev/shm
tmpfs            182M  892K  181M   1% /run
efivarfs         128K  3.1K  120K   3% /sys/firmware/efi/efivars
tmpfs            455M  4.0K  455M   1% /tmp
none             1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
none             1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
/dev/nvme0n1p13  989M   96M  826M  11% /boot
/dev/nvme0n1p15  105M  6.3M   99M   7% /boot/efi
none             1.0M     0  1.0M   0% /run/credentials/systemd-networkd.service
none             1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
none             1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyS0.service
tmpfs             91M  8.0K   91M   1% /run/user/1000
```

### 8.Command:

```bash
du -sh /var/log
```

```text
Calculates folder size.

du

Disk Usage.

-s

Summary only.

-h

Human readable.
```

### Output:

```text
du: cannot read directory '/var/log/amazon': Permission denied
du: cannot read directory '/var/log/chrony': Permission denied
du: cannot read directory '/var/log/private': Permission denied
17M     /var/log
```

## Network

### 9.Command:

```bash
ss -tulpn
```

```text
Shows network sockets. Which applications are listening on which ports?
```

### Output:

```text
Netid          State           Recv-Q          Send-Q                        Local Address:Port                   Peer Address:Port          Process
udp            UNCONN          0               0                                 127.0.0.1:323                         0.0.0.0:*
udp            UNCONN          0               0                                127.0.0.54:53                          0.0.0.0:*
udp            UNCONN          0               0                             127.0.0.53%lo:53                          0.0.0.0:*
udp            UNCONN          0               0                        172.31.32.178%ens5:68                          0.0.0.0:*
udp            UNCONN          0               0                                     [::1]:323                            [::]:*
tcp            LISTEN          0               4096                             127.0.0.54:53                          0.0.0.0:*
tcp            LISTEN          0               4096                          127.0.0.53%lo:53                          0.0.0.0:*
tcp            LISTEN          0               4096                                0.0.0.0:22                          0.0.0.0:*
tcp            LISTEN          0               4096                                   [::]:22                             [::]:*
```

### 10.Command:

```bash
curl -I https://google.com
```

```text
Sends a request and retrieves only headers.
```

### Output:

```text
HTTP/2 301
location: https://www.google.com/
content-type: text/html; charset=UTF-8
content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-sIhPOeyV1FNm8C3DdOhVcQ' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
date: Wed, 03 Jun 2026 04:13:52 GMT
expires: Fri, 03 Jul 2026 04:13:52 GMT
cache-control: public, max-age=2592000
server: gws
content-length: 220
x-xss-protection: 0
x-frame-options: SAMEORIGIN
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
```

## Logs

### 11.Command:

```bash
journalctl -u ssh -n 50
```

```text
Reads logs managed by systemd.
```

#### Output:

```text
Jun 03 03:52:06 ip-172-31-32-178 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Jun 03 03:52:06 ip-172-31-32-178 sshd[1016]: Server listening on 0.0.0.0 port 22.
Jun 03 03:52:06 ip-172-31-32-178 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
Jun 03 03:52:06 ip-172-31-32-178 sshd[1016]: Server listening on :: port 22.
Jun 03 03:54:15 ip-172-31-32-178 sshd-session[1147]: Accepted publickey for ubuntu from 223.236.99.30 port 18978 ssh2: RSA SHA256:mpWip5Zva9+9eovtG8i47YrQwb2>
Jun 03 03:54:15 ip-172-31-32-178 sshd-session[1147]: pam_unix(sshd:session): session opened for user ubuntu(uid=1000) by ubuntu(uid=0)
Jun 03 03:57:13 ip-172-31-32-178 sshd-session[1311]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:8EmkLy2nCIk06b>
Jun 03 03:57:14 ip-172-31-32-178 sshd-session[1311]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:7XnmSnhPkjXzpd>
Jun 03 03:57:14 ip-172-31-32-178 sshd-session[1311]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:01L8QvuaTRkTop>
Jun 03 03:57:14 ip-172-31-32-178 sshd-session[1311]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:qycNKo9Xh8/MQ1>
Jun 03 03:57:15 ip-172-31-32-178 sshd-session[1311]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:IgXgwUUgk3QuXG>
Jun 03 03:57:15 ip-172-31-32-178 sshd-session[1311]: Received disconnect from 78.111.67.242 port 46224:11: disconnected by user [preauth]
Jun 03 03:57:15 ip-172-31-32-178 sshd-session[1311]: Disconnected from authenticating user root 78.111.67.242 port 46224 [preauth]
Jun 03 04:00:38 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:awqEyzxYerj5vs>
Jun 03 04:00:38 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:A14iaMcufzEJVV>
Jun 03 04:00:38 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:SuY/13Y+1oQuHx>
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:/Nul8vqpxP+bcG>
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys root SHA256:71IJnFiB+sCbAp>
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: Received disconnect from 87.121.69.138 port 27986:11: disconnected by user [preauth]
Jun 03 04:00:39 ip-172-31-32-178 sshd-session[1410]: Disconnected from authenticating user root 87.121.69.138 port 27986 [preauth]
Jun 03 04:00:47 ip-172-31-32-178 sshd-session[1483]: Connection closed by 68.183.87.42 port 44158 [preauth]
```

### 12.Command

```bash
tail -n 5 /var/log/syslog
```

```text
Shows last 5 lines of a file.
```

#### Output:

```text
2026-06-03T04:07:06.782845+00:00 ip-172-31-32-178 systemd[1]: Finished systemd-tmpfiles-clean.service - Cleanup of Temporary Directories.
2026-06-03T04:10:06.803642+00:00 ip-172-31-32-178 systemd[1]: Starting sysstat-collect.service - system activity accounting tool...
2026-06-03T04:10:06.825002+00:00 ip-172-31-32-178 systemd[1]: sysstat-collect.service: Deactivated successfully.
2026-06-03T04:10:06.825290+00:00 ip-172-31-32-178 systemd[1]: Finished sysstat-collect.service - system activity accounting tool.
2026-06-03T04:17:01.695995+00:00 ip-172-31-32-178 CRON[1785]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
```

## The Actual DevOps Troubleshooting Flow . When a service fails, most DevOps engineers follow this sequence:

```text
1. systemctl status service
        ↓
2.      ps
        ↓
3.  free -h
        ↓
4.  df -h
        ↓
5.  ss -tulpn
        ↓
6.  journalctl
        ↓
7.  tail logs
        ↓
8.  Fix root cause
```

## This progression answers the key questions:

```text
- Is the service running?
- Is it consuming excessive resources?
- Is the server out of memory?
- Is the disk full?
- Is the port open?
- What do the logs say?
```






