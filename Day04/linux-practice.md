# Day 04 – Linux Practice: Processes and Services

## Process Check

### 1. View Running Processes 

Command:

```bash
ps aux | head
```

Output:

```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.7  1.7  25208 16060 ?        Ss   06:38   0:02 /sbin/init
root           2  0.0  0.0      0     0 ?        S    06:38   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    06:38   0:00 [pool_workqueue_release]
root           4  0.0  0.0      0     0 ?        I<   06:38   0:00 [kworker/R-rcu_gp]
root           5  0.0  0.0      0     0 ?        I<   06:38   0:00 [kworker/R-sync_wq]
root           6  0.0  0.0      0     0 ?        I<   06:38   0:00 [kworker/R-kvfree_rcu_reclaim]
root           7  0.0  0.0      0     0 ?        I<   06:38   0:00 [kworker/R-slub_flushwq]
root           8  0.0  0.0      0     0 ?        I<   06:38   0:00 [kworker/R-netns]
root           9  0.0  0.0      0     0 ?        I    06:38   0:00 [kworker/0:0-events]
```

### 2. Find a Specific Process

Command:

```bash
pgrep -a ssh 
```

Output:

```text
1082 sshd: /usr/sbin/sshd -D -o AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys %u %f -o AuthorizedKeysCommandUser ec2-instance-connect [listener] 0 of 10-100 startups
1150 sshd-session: ubuntu [priv]
1267 sshd-session: ubuntu@pts/0

```

## Service Check

### 3. Check status ssh

Command:

```bash
systemctl status ssh
```

Output:

```text
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/usr/lib/systemd/system/ssh.service; disabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/ssh.service.d
             └─ec2-instance-connect.conf
     Active: active (running) since Tue 2026-06-02 06:38:19 UTC; 12min ago
 Invocation: e1417069ab5e4c25b49718070b241ef2
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 1074 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 1082 (sshd)
      Tasks: 1 (limit: 627)
     Memory: 7.1M (peak: 8M)
        CPU: 73ms
     CGroup: /system.slice/ssh.service
             └─1082 "sshd: /usr/sbin/sshd -D -o AuthorizedKeysCommand /usr/share/ec2-instance-connect/eic_run_authorized_keys %u %f -o AuthorizedKeysCommandU>

Jun 02 06:38:19 ip-172-31-38-83 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Jun 02 06:38:19 ip-172-31-38-83 sshd[1082]: Server listening on 0.0.0.0 port 22.
Jun 02 06:38:19 ip-172-31-38-83 sshd[1082]: Server listening on :: port 22.
Jun 02 06:38:19 ip-172-31-38-83 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
Jun 02 06:42:07 ip-172-31-38-83 sshd-session[1150]: Accepted publickey for ubuntu from 223.236.99.37 port 14867 ssh2: RSA SHA256:mpWip5Zva9+9eovtG8i47YrQwb2g>
Jun 02 06:42:07 ip-172-31-38-83 sshd-session[1150]: pam_unix(sshd:session): session opened for user ubuntu(uid=1000) by ubuntu(uid=0)
```


### 4.List Running Services

Command:

```bash
systemctl list-units --type=service --state=running

```

Output:

```text
  UNIT                                           LOAD   ACTIVE SUB     DESCRIPTION
  acpid.service                                  loaded active running ACPI event daemon
  chrony.service                                 loaded active running chrony, an NTP client/server
  cron.service                                   loaded active running Regular background program processing daemon
  dbus.service                                   loaded active running D-Bus System Message Bus
  getty@tty1.service                             loaded active running Getty on tty1
```


## Log Checks

### 5.View Service Logs

Command:

```bash
journalctl -u ssh --no-pager | tail -10
```

Output:
```text
Jun 02 06:38:19 ip-172-31-38-83 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Jun 02 06:38:19 ip-172-31-38-83 sshd[1082]: Server listening on 0.0.0.0 port 22.
Jun 02 06:38:19 ip-172-31-38-83 sshd[1082]: Server listening on :: port 22.
Jun 02 06:38:19 ip-172-31-38-83 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
Jun 02 06:42:07 ip-172-31-38-83 sshd-session[1150]: Accepted publickey for ubuntu from 223.236.99.37 port 14867 ssh2: RSA SHA256:mpWip5Zva9+9eovtG8i47YrQwb2gKIy162/6q6am7z0
Jun 02 06:42:07 ip-172-31-38-83 sshd-session[1150]: pam_unix(sshd:session): session opened for user ubuntu(uid=1000) by ubuntu(uid=0)
```

### 6. View Recent System Logs

Commands:
```bash
tail -n 3 /var/log/syslog
```

Output:
```text
2026-06-02T06:53:18.333087+00:00 ip-172-31-38-83 systemd[1]: Starting systemd-tmpfiles-clean.service - Cleanup of Temporary Directories...
2026-06-02T06:53:18.443796+00:00 ip-172-31-38-83 systemd[1]: systemd-tmpfiles-clean.service: Deactivated successfully.
2026-06-02T06:53:18.444060+00:00 ip-172-31-38-83 systemd[1]: Finished systemd-tmpfiles-clean.service - Cleanup of Temporary Directories.
```

### 7.Mini Troubleshooting Steps

#### Problem

##### Verify that the SSH service is running and accepting connections.

#### Steps Taken

1. Checked for SSH processes:
```bash
pgrep -a ssh
```

2. Verified service status:
```bash
systemctl status ssh
```
3.Reviewed recent SSH logs:
```bash
journalctl -u ssh --no-pager | tail -10
```


#### Result

- SSH process was running.
- SSH service status showed active (running).
- Logs showed successful login activity.
- No errors were detected.


























