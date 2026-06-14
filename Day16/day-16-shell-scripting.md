# Day 16 - Shell Scripting Basics

## Task 1: Your First Script

### Create a 'hello.sh' file

#### Script:
```bash
#!/bin/bash

echo "Hello, Devops"
```

#### Make it Executable and Run it
```bash
chmod +x hello.sh
./hello.sh
```

#### Expected Output
```text
Hello, Devops
```

---

## Task 2: Variable

### create a 'variable.sh' file

#### Script:
```bash
#!/bin/bash

NAME="Aditya"

ROLE="Devops Engineer"

echo "hello, I am $NAME and I am a $ROLE"

```
#### Make it exectuable and Run it
```bash
chmod +x variable.sh
./variable.sh
```

#### Output and screenshot:

![variable](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/714fc3c3e80bd875e4e35e0fd1c9aed6698b9b9f/images/16%204.png)


#### Single quote Script:
```bash
#!/bin/bash

NAME='Aditya'

ROLE='Devops Engineer'

echo 'hello, I am $NAME and I am a $ROLE'
```

#### Output and Screenshot:

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/17c9e12c1b06c2741c53f9f36c9b47f9f848c321/images/16%20single%201.png)
---

## Task 3: User Input with read

### create a 'greet.sh' file

#### Script:
```bash
#!/bin/bash

echo "Enter your name:"
read name

echo "Enter your Favourite tool"
read tool

echo "Hello $name, your favourite tool is $tool"

```

#### Make it executable and Run it
```bash
chmod +x greet.sh
./greet.sh
```

#### Output and Screenshot:

![greet](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/1c8739701263935e3919b78c0867b334637c7df5/images/16%20greet.sh.png)

---

## Task 4: If-Else Conditions

### create a 'check_number.sh' file

#### Script:
```bash
#!/bin/bash

echo "Enter Your Number:"
read num

if [ "$num" -gt 0 ]; then
        echo "Postive Number"
elif [ "$num" -lt 0 ]; then
        echo "Negative Number"
else
        echo "Zero"
fi
```

#### Make is exectuable and Run it
```bash
chmod +x check_numer.sh
./check_number.sh
```

#### Output and Screenshot:

![if_else](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/1c8739701263935e3919b78c0867b334637c7df5/images/16%20if%20eq.png)


### Create a 'file_check.sh'

#### Script:
```bash
#!/bin/bash
echo "Enter filename:"
read filename
if [ -f "$filename" ]; then
        echo "File exists."
else
        echo "File does not exist."
fi

```

#### Make it Executable and run it
```bash
chmod +x file_check.sh
./file_check.sh
```

#### Output and Screenshot:

![file_check](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/17c9e12c1b06c2741c53f9f36c9b47f9f848c321/images/16%20file.png)

---

## Task 5: Combine It All

### Create a 'server_check.sh' file

#### Script:
```bash
#!/bin/bash

SERVICE="ssh"

echo "Enter your choice:"
read choice

if [ "$choice" = "y" ]; then

        if systemctl is-active --quiet "$SERVICE"; then
                echo "Service is active."
        else
                echo "Service is inactive."
        fi

elif
        [ "$choice" = "n" ]; then
        echo "Skipped."
else
        echo "Invalid choice."
fi

```

#### make it executable and run it:
```bash
chmod +x server_check.sh
./server_check.sh
```

#### Output and Screenshot:

![server](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/17c9e12c1b06c2741c53f9f36c9b47f9f848c321/images/16%20server.png)

---

## Key Concepts Learned

- ✅ What shell scripting is

- ✅ Importance of shebang (#!/bin/bash)

- ✅ Creating executable scripts

- ✅ Variables and variable expansion

- ✅ Difference between single and double quotes

- ✅ Taking user input using read

- ✅ Writing if, elif, and else conditions

- ✅ Checking file existence using -f

- ✅ Checking service status using systemctl

- ✅ Combining variables, input, and conditions into a practical script
