# Day 20 - Bash Scripting challenge: Log analyzer and report

## Task 1: Input Validation

### Purpose: 
-   Ensure the user provides a valid log file before starting analysis

#### Script:
```script
#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Error: Please provide a log file path."
    exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File does not exist."
    exit 1
fi

```

## Task 2: Error Count

### Purpose:
- Count all line containing : 
- 1.ERROR
- 2.FAILED

#### Script:
```script
ERROR_COUNT=$(grep -Ei "ERROR|Failed" "$LOG_FILE" | wc -l)
```

---

## Task 3: Critical Events Detection

### Purpose:
- Identify system events marked as CRITICAL.

#### Script
```script
CRITICAL_EVENTS=$(grep -n "CRITICAL" "$LOG_FILE" || true)
```

---

## Task 4: Top 5 Error Messages

### Purpose:
- Find the most frequently occurring error messages.

#### Script:
```script
TOP_ERRORS=$(grep "ERROR" "$LOG_FILE" \
    | sed 's/.*ERROR[: ]*//' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -5)

```

---

## Task 5: Generate Summary Report

### Purpose
- Save analysis results into a text file.

#### Script:
```script
DATE=$(date +%Y-%m-%d)
REPORT_FILE="log_report_${DATE}.txt"
```

---

## Task 6: Archive Processed Logs

### Purpose:
- Move analyzed logs to a separate directory.

- This prevents reprocessing the same file.

#### Script:
```script
mkdir -p archive

mv "$LOG_FILE" archive/
```

---

## Full Script:

```script
#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Error: Please provide a log file path."
    exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File does not exist."
    exit 1
fi

DATE=$(date +%Y-%m-%d)
REPORT_FILE="log_report_${DATE}.txt"

TOTAL_LINES=$(wc -l < "$LOG_FILE")

ERROR_COUNT=$(grep -Ei "ERROR|Failed" "$LOG_FILE" | wc -l)

CRITICAL_EVENTS=$(grep -n "CRITICAL" "$LOG_FILE" || true)

TOP_ERRORS=$(grep "ERROR" "$LOG_FILE" \
    | sed 's/.*ERROR[: ]*//' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -5)

echo "============================"
echo "Log Analysis Report"
echo "============================"
echo "Log File: $LOG_FILE"
echo "Total Errors: $ERROR_COUNT"
echo

echo "--- Critical Events ---"
if [ -n "$CRITICAL_EVENTS" ]; then
    echo "$CRITICAL_EVENTS"
else
    echo "No critical events found."
fi

echo
echo "--- Top 5 Error Messages ---"
if [ -n "$TOP_ERRORS" ]; then
    echo "$TOP_ERRORS"
else
    echo "No error messages found."
fi

{
    echo "====================================="
    echo "Daily Log Analysis Report"
    echo "====================================="
    echo "Date of Analysis : $DATE"
    echo "Log File         : $LOG_FILE"
    echo "Total Lines      : $TOTAL_LINES"
    echo "Total Errors     : $ERROR_COUNT"
    echo

    echo "Top 5 Error Messages"
    echo "-------------------------------------"

    if [ -n "$TOP_ERRORS" ]; then
        echo "$TOP_ERRORS"
    else
        echo "No error messages found."
    fi

    echo
    echo "Critical Events"
    echo "-------------------------------------"

    if [ -n "$CRITICAL_EVENTS" ]; then
        echo "$CRITICAL_EVENTS"
    else
        echo "No critical events found."
    fi

} > "$REPORT_FILE"

mkdir -p archive

mv "$LOG_FILE" archive/

echo
echo "Report generated: $REPORT_FILE"
echo "Log file archived successfully."

```

---


