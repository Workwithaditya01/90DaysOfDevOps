# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

### Task 1: Log rotation script:

#### Create 'log_rotate.sh :

```script
#!/bin/bash

set -euo pipefail

LOG_DIR="$1"

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

COMPRESSED_COUNT=0
DELETED_COUNT=0

while IFS= read -r file
do
    gzip "$file"
    ((COMPRESSED_COUNT++))
done < <(find "$LOG_DIR" -type f -name "*.log" -mtime +7)

while IFS= read -r file
do
    rm -f "$file"
    ((DELETED_COUNT++))
done < <(find "$LOG_DIR" -type f -name "*.gz" -mtime +30)

echo "Compressed files: $COMPRESSED_COUNT"
echo "Deleted files: $DELETED_COUNT"
```

---

### Task 2: Server Backup Script:

#### Create 'backup.sh' :

```script
#!/bin/bash

set -euo pipefail

SOURCE_DIR="$1"
BACKUP_DIR="$2"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y-%m-%d)

ARCHIVE_NAME="backup-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

tar -czf "$ARCHIVE_PATH" "$SOURCE_DIR"

if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "Backup creation failed."
    exit 1
fi

SIZE=$(du -h "$ARCHIVE_PATH" )

echo "Backup created:"
echo "Archive: $ARCHIVE_NAME"
echo "Size: $SIZE"

find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +14 -delete

echo "Old backups cleaned."

```

---

## Task 3: Crontab

### Cron Syntax

```cron
* * * * *  command
│ │ │ │ │
│ │ │ │ └── Day of week (0-7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

### Cron entries:

#### 1.Log Rotation Every Day at 2 AM

```output
0 2 * * * /home/user/log_rotate.sh /var/log/myapp
```

#### 2.Backup Every Sunday at 3 AM

```output
0 3 * * 0 /home/user/backup.sh /var/www /backups
```

#### 3.Health Check Every 5 Minutes

```output
*/5 * * * * /home/user/health_check.sh
```

### 4.Maintenance Script Daily at 1 AM

```output
0 1 * * * /home/user/maintenance.sh
```

---

## Task 4: Combine - Scheduled maintenance script

### Create 'maintenance.sh'

```script
#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/maintenance.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

rotate_logs() {

    LOG_DIR="$1"

    if [ ! -d "$LOG_DIR" ]; then
        log_message "Log directory not found."
        return 1
    fi

    find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec gzip {} \;

    find "$LOG_DIR" -type f -name "*.gz" -mtime +30 -delete

    log_message "Log rotation completed."
}

backup_server() {

    SOURCE_DIR="$1"
    BACKUP_DIR="$2"

    if [ ! -d "$SOURCE_DIR" ]; then
        log_message "Source directory missing."
        return 1
    fi

    mkdir -p "$BACKUP_DIR"

    TIMESTAMP=$(date +%Y-%m-%d)

    tar -czf "$BACKUP_DIR/backup-${TIMESTAMP}.tar.gz" "$SOURCE_DIR"

    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +14 -delete

    log_message "Backup completed."
}

rotate_logs "/var/log/myapp"

backup_server "/var/www" "/backups"

log_message "Maintenance completed successfully."
```

---

## What I Learned

1. Automating file management using find, gzip, and tar.
2. Scheduling tasks with Cron for regular maintenance.
3. Building reusable Bash functions with proper error handling.

---


