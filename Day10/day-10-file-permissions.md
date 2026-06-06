# Day 10 – File Permissions & File Operations Challenge

## Task 1: Create Files

### Create an empty file

#### Command:

```bash
touch devops.txt
```
### Create notes.txt with content using echo

#### Command:

```bash
echo "Linux Basic Permission" > notes.txt
```

#### Verify:

```bash
cat notes.txt
```

### create script.sh File using vim

#### Commands:

```bash
vim script.sh
```

#### Insert Data:

```bash
echo "Hello Devops"
```

---

## Task 2: Read Files 

### Read notes.txt

#### Commands:

```bash
cat notes.txt
```

```Output
Linux Basic Permission
```

### View script.sh in Read-only mode

#### Command:

```bash
vim -R script.sh
```

### Display First 5 Line of /etc/passwd

#### Commands:

```bash
head -n 5 /etc/passwd
```

#### Expected Output:

```Output
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
```

#### Display last 5 Lines of /etc/passwd

#### Commands:

```bash
tail -n 5 /etc/passwd
```

#### Output:

```output
landscape:x:103:106::/var/lib/landscape:/usr/sbin/nologin
fwupd-refresh:x:984:984:Firmware update daemon:/var/lib/fwupd:/usr/sbin/nologin
polkitd:x:983:983:User for polkitd:/:/usr/sbin/nologin
ec2-instance-connect:x:104:65534::/nonexistent:/usr/sbin/nologin
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
```

---

## Task 3: Under Permission

### check Permission

#### Command:

```bash
ls -l
```
#### Output:

```output
-rw-rw-r-- 1 ubuntu ubuntu  0 Jun  6 11:56 devops.txt
-rw-rw-r-- 1 ubuntu ubuntu 23 Jun  6 11:58 notes.txt
-rw-rw-r-- 1 ubuntu ubuntu 20 Jun  6 12:00 script.sh
```

### Permission breakdown

#### Format: rwxrwxrwx

```bash
    rwx-rwx-rwx
     |   |   |
     |   |  Other
     |  Group
    Owner
```

#### Meaning

| Permission | value | Meaning |
|------------|-------|---------|
| r | 4 | read |
| w | 2 | write |
| x | 1 | exectue |
|---|---|---------|

---

## Task 4: Modify Permission

### make script.sh executable

#### Command:

```bash
chmod +x script.sh
```

#### Verify

```bash
ls -l
```
#### Output:

```Output
-rwxrwxr-x 1 ubuntu ubuntu 20 Jun  6 12:00 script.sh
```

#### Run script:

```bash
./script.sh
```

#### Output:

```output
Hello Devops
```

### Set devops.txt to read-only

#### Command:

```bash
chmod a-w devops.txt
```

#### Verify:

```bash
ls -l
```

#### Output:

```output
-r--r--r-- 1 ubuntu ubuntu 0 Jun  6 11:56 devops.txt
```

### Set notes.txt to 640

#### Command:

```bash
chmod 640 notes.txt 
```

#### Verify:

```bash
ls -l notes.txt
```

#### Output:

```bash
-rw-r----- 1 ubuntu ubuntu 23 Jun  6 11:58 notes.txt
```

### Create Project Directory with 755 permission

#### Commands:

```bash
mkdir project

chmod 755 project
```

#### Verify:

```bash
ls -ld
```

#### output:

```output
drwxr-xr-x 2 ubuntu ubuntu 4096 Jun  6 12:39 project
```

---

## Task 5: test Permission

### Try Writing in Read-only file

#### Command:

```bash
echo "testing" > devops.txt
```

#### Output:

```Output
-bash: devops.txt: Permission denied
```

### Try Exectuing a file without exectue permission

#### Command:

```bash
chmod -x script.sh

./script.sh
```

#### Output:

```Output
-bash: ./script.sh: Permission denied
```
---
















