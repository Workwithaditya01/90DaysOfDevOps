# Day 17 - Shell Scripting: loops Arguments & Error handling

## Task 1: for loops

### Script:

```command
#!/bin/bash

for fruit in Apple Banana Mango Orange Graphes
do 
    echo "$fruit"
done

```

### Output:
![for](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/989644096dc189742b020ed2cead1aa456fc920a/images/17%20for.sh.png)

---

## Task 2: While Loops

### Script:

```script
#!/bin/bash

echo"Enter a Number"
read num

while [ "$num" -ge 0 ]
do
    echo "$num"
    num = $((num-1))
done
```

### Output
![while](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/989644096dc189742b020ed2cead1aa456fc920a/images/17%20count.sh.png)

---

## Task 3: Command-line argument

### Script:

```command
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./greet.sh <name>"
else
    echo "Hello, $1!"
fi
```

### Output:

![cmd](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/989644096dc189742b020ed2cead1aa456fc920a/images/17%20cmd.sh.png)

### Script:

```command
#!/bin/bash

echo "Script Name: $0"
echo "Total argument: $#"
echo "All argument: $@"
```

### Output:

![args](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/989644096dc189742b020ed2cead1aa456fc920a/images/17%20args.sh.png)

---

## TasK 4: Installing package via script

### Script:

```script
#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Run this script as root."
    exit 1
fi

PACKAGES="nginx curl wget"

for pkg in $PACKAGES
do
    if dpkg -s "$pkg" &>/dev/null; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        apt update -y
        apt install -y "$pkg"
    fi
done

```

### Output:

![package](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/989644096dc189742b020ed2cead1aa456fc920a/images/17%20packages.sh.png)

---

## Task 5: Error handling

### Script

```script
#!/bin/bash

set -e

mkdir /tmp/devops-test || echo "Directory already exists"

cd /tmp/devops-test || {
    echo "Failed to enter directory"
    exit 1
}

touch test.txt || {
    echo "Failed to create file"
    exit 1
}

echo "File created successfully."
echo "Script completed successfully."

```

### Output:

![EH](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/989644096dc189742b020ed2cead1aa456fc920a/images/17%20safe.sh.png)

---

## What I Learned

### 1. Loops Automate Repetitive Tasks
- Used for loops to iterate through lists.
- Used while loops for repeated execution based on conditions.

### 2. Command-Line Arguments Make Scripts Flexible
- Accessed arguments using $1.
- Counted arguments using $#.
- Displayed all arguments using $@.
### 3. Error Handling Improves Reliability
- Used set -e to stop execution on errors.
- Used || operators to handle failures gracefully.
- Added root-user validation before installing packages.
