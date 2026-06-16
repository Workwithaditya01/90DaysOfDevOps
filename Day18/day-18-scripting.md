# Day 18 – Shell Scripting: Functions & Intermediate Concepts

## Task 1: Basic Function

### Script:function.sh

```script
#!/bin/bash

greet() {
        echo "Hello, $1!"
}

add() {
        echo $(($1+$2))
}

greet "Aditya"
echo "Sum: $(add 10 20)"

```

### Expected Output:

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/c52a579405362a300c3c229eaf4bc7294e18738c/images/Day%2018/Function.sh%20out.png)
---

## Task 2: Functions with return values

### script: disk_check.sh

```script
#!/bin/bash

check_disk(){
        echo "disk usage:"
        df -h /
}

check_memory(){
        echo "Memory usage:"
        free -h
}

echo "################## System Resoure Check ######################"

check_disk

echo

check_memory

```

### Expected Output:

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/c52a579405362a300c3c229eaf4bc7294e18738c/images/Day%2018/disk_check%20out.png)

---

## Task 3: Strict mode - set -euo pipefail

### Script:strict_demo.sh

```script
#!/bin/bash
set -euo pipefail

echo "Testing set -u"
echo "$UNDEFINED_VAR"

echo "Testing set -e"
false

echo "Testing pipefail"
cat missing_file.txt | grep hello

echo "Script Finished

```

### Expected Output:

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/c52a579405362a300c3c229eaf4bc7294e18738c/images/Day%2018/strict_demo%20out.png)

---

## Task 4: Local variable

### Script:local_demo.sh

```script
#!/bin/bash

local_function(){
        local name="Local Variable"
        echo "Inside function: $name"
}

regular_function(){
        name="global Variable"
        echo "Inside Function: $name"
}
local_function

echo "Outside Function: ${name:-not available}"

regular_function

echo "Outside Function: $name"

```

### Expected output:

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/c52a579405362a300c3c229eaf4bc7294e18738c/images/Day%2018/local_demo%20out.png)

---


## Task 5: System info reporter

### Script:system_info.sh

```script
#!/bin/bash

# Enable strict mode
set -euo pipefail

print_header() {
    echo "======================================="
    echo "$1"
    echo "======================================="
}
system_info() {
    echo "Hostname: $(hostname)"
    echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
}

uptime_info() {
    uptime -p
}
disk_usage(){
    du -ah / 2>/dev/null | sort -rh | head -5
}

memory_usage() {
    free -h
}

top_cpu_processes() {
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -6
}
main() {
    print_header "SYSTEM INFORMATION"
    system_info

    print_header "SYSTEM UPTIME"
    uptime_info

    print_header "TOP 5 DISK USAGE"
    disk_usage

    print_header "MEMORY USAGE"
    memory_usage

    print_header "TOP 5 CPU PROCESSES"
    top_cpu_processes
}

main

```

### Expected Output:

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/014b0e94a17c8a4fb6fc080d8cd8fe205da54856/images/Day%2018/system_info%20out.png)

---

## What I Learned

### 1. Functions Make Scripts Reusable

- Functions reduce code duplication and improve readability.

### 2. Strict Mode Improves Reliability

- Using set -euo pipefail helps detect errors quickly and prevents unexpected behavior.

### 3. Local Variables Improve Safety

- Using local inside functions prevents variable conflicts and keeps scripts clean.

---

