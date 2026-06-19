# Day 21 – Shell Scripting Cheat Sheet: Build Your Own Reference Guide

## Quick Reference Table
| Topic | Key Syntax | Example|
|-------|------------|--------|
| Variable | VAR="value" | NAME="DevOps" |
| Argument | $1, $2	| ./script.sh arg1 |
| If Statement | if [ condition ]; then | if [ -f file ]; then |
| For Loop | for i in list; do | for i in 1 2 3; do |
| Function | name() { ... } | greet() { echo "Hi"; } |
| Grep  |	grep pattern file |	grep -i "error" log.txt |
| Awk | awk '{print $1}' file |	awk -F: '{print $1}' /etc/passwd |
| Sed | sed 's/old/new/g' file |sed -i 's/foo/bar/g' config.txt |

## Task 1: Basics

### Shebang 

```shebang
#!/bin/bash
```
- Defines which interpreter executes the script.
- #!/bin/bash: This exectues the script in bash interpreter.
- #!/bin/sh: This executes the script in shell interpreter

---

### How to Run a Script:

#### Make the file executable:

- If a user creates file. The file has permission to read, write and execute. 

#### Check the file whether it has execute permission

##### Command:

```command
ls -l
```
##### Output:

```output
-rw-r--r-- 1 Aditya 197121 1382 Jun  8 12:13 script.sh
```
- This file doesn't have execute permission
- To add execute permission you need to run a command

```command
chmod +x script.sh
```
- This adds the execute permission to the script

```output
-rwxr-xr-x 1 Aditya 197121 1382 Jun  8 12:13 script.sh
```
---

#### Execute the Script:

##### Command:

```command
./script.sh
```
- this command executes the script written by user

##### Run with bash:

```Command
bash script.sh
```
---

### Comments:

#### Importance of Comment

- Comments are primarily used to explain the intent, logic, and purpose of code, making scripts easier for humans to read and maintain.  
- Since comments are ignored by the interpreter during execution.

#### Single-Line Comments:

```script
# This is a comment
```

#### Inline Comments:

```script
echo "Hello" # Prints Hello
```
---

### Variable

#### How to Declare a Variable:
```variable
NAME="ADITYA"
```

#### How to Use a Variable:
```Variable
echo $NAME
```

#### Double Quotes Expand Variable
```variable
echo "My name is $NAME"
```

#### Single Quotes treats text literally:
```variable
echo '$NAME'
```

---

### Reading - User Input:

#### How to read a user input:
```user_input
read -p "Enter name: " NAME
```
- The Variable Declared after the double quotes it is the variable where value is stored. 

#### Print User Input :
```Print_input
echo "Welcome $NAME"
```

### Command-line argument:

- Command-line arguments Script takes the user input at the time of execution.

```cla
echo $1
echo $0
echo $@
echo $#
```

#### How to execute command-line argument script:
```Command
./script.sh devops linux
```

---
***
---

## Task 2: Operators and Conditionals

### String Comparisons

| String | Explaination |
|--------|--------------|
| [ "$A" = "$B" ] | Returns true if the string value of variable $A is equal to $B. |
| [ "$A" != "$B" ] | Returns true if the string value of variable $A is not equal to $B. |
| [ -z "$A" ] | Returns true if the lenght of string is Zero. |
| [ -n "$A" ] | Returns True if the lenght of string is non-zero. |
|-----------|--------------|

---

### Integer Comparison

| Integer | Explaination |
|---------|--------------|
| [ "$A" -eq "$B" ] | Returns True if variable $A is equal to $B |
| [ "$A" -ne "$B" ] | Returns True if variable $A is not equal to $B |
| [ "$A" -lt "$B" ] | Returns True if variable $A is less then to $B |
| [ "$A" -gt "$B" ] | Returns True if variable $A is Greater then $B |
|-----------|---------------|

--- 

### File Test Operators

| Operators | Use-Case |
|-----------|----------|
| -f file | Returns True if the file path exist and is a Regular file. |
| -d directory |  Returns True if the File path exist and is a directory. |
| -e file | Returns True if the file path exist . regardless of file, directory, links etc. |
| -r file | Returns True if the file exist and is readable by the current user. |
| -w file | Returns True if the file exist and is writable by the current user. |
| -x file | Returns True if the file exist and is executable by the current user. |
| -s file | Returns True if the file exist and file size if greater then zero. |
|--------|---------------|

---

### if/elif/else

#### Example:

```script
#!/bin/bash

set -euo pipefail

AGE=$1

if [ "$AGE" -gt 18 ]; then
    echo "Adult"
elif [ "$AGE" -gt 13 ]; then 
    echo "Teen"
else
    echo "child"
fi

```

#### Explaination:

- 'set -euo pipefail' : It is a Safety command used to prevent script running if any command fails. 
- 'AGE=$1' : Take the user input and sort it in variable 'AGE'.
- 'if [ "$AGE" -gt 18 ]; then' : This line check whether the INPUT sorted in Variable 'AGE' is greater then 18.
- 'echo "Adutl" ' : if the value sorted in variable 'AGE' is greater then 18 it prints 'ADULT'
- 'elif [ "$AGE" -gt 13 ]; then' : if the 1st condition false then it checks the 2nd condition whether value sorted if variable is greater then 13.
- 'echo "Teen"' : if the value sorted in variable 'AGE' is greater then 13 it print Teen
- 'else echo "Child"' : And if both condition is false then it print child.
- 'fi' : fi command is used to end the if statement.

---

### Logical Operators:

#### AND:

```AND
[ -f file ] && echo "Exists"
```

#### Explaination of AND Operator:

- '[ -f file ]': Test the file path exist and is regular file
- '[&&]': Executes the command on the right only if the command on the left succeeds.
- 'echo "Exists"': Prints "Exists" on the terminal

#### OR:

```OR
[ -f file ] || echo "Missing"
```

#### Explaination Of OR Operator:

- '[ -f file ]': Test if the file path exist and is regular file
- '[||]': Executes the command on the right only if the command on the left is false. It is OR Operator there is two option this or that.
- 'echo "Missing"': Prints "Missing " on the terminal

#### NOT:

```NOT
[ ! -f file]
```

#### Explaination of NOT Operator:

- '[! -f file]': Test if the file path is NOT regular file.

---

### Case Statement

#### Script
```script
case $CHOICE in
    start)
        echo "Starting"
        ;;
    stop) 
        echo "Stopping"
        ;;
    *)
        echo "Invalid option"
        ;;
esac
```

#### Explaination

- 'case $CHOICE in' : Evaluates the value of '$CHOICE'
- 'start)' : if '$CHOICE' matches "start", it executes 'echo "Starting"'
- ';;' : Maeks the end of the commands for each specific case.
- 'stop)' : if '$CHOICE' matches "stop", it executes 'echo "Stopping"'
- '*)' : if the '$CHOICE' matches neither then is executes 'echo "Invalid Option"'

---
***
---

## Task 3: Loops

### For Loop

#### List-based:

for i in 1 2 3 4 
do 
    echo $i
done

#### C-style:

for ((i=1; i<=5; i++))
do 
    echo $i
done

#### Explaination

- 'for i in 1 2 3 4 ': Initializes the loop, assigning each value from the list one by one .
- 'for ((i=1; i<=5; i++))': Initializes the loop, i start from 1 and increaments (i++) until i is less then equal to 5 (i<=5).
- 'echo $i' : Prints each value of i from the loop

---

### While Loop

```while
COUNT=1

while [ $COUNT -le 5 ]
do
    echo $COUNT
    ((COUNT++))
done

```

#### Explaination

- 'COUNT=1': An variable named 'COUNT' is declared with value assigned to it 1.
- 'while [ $COUNT -le 5 ]' : if the value of variable '$COUNT' it while execute the 'do' condition until value of '$COUNT' is less then equal to 5.
- '((COUNT++))' : Increaments the value of variable '$COUNT'.

---

### Until Loop

```until
COUNT=1

until [ $COUNT -gt 5 ]
do 
    echo $COUNT
    ((COUNT++))
done
```

#### Explaination

- 'until [ $COUNT -gt 5 ]': Checks if $COUNT is greater than 5.
- If false (COUNT ≤ 5): The loop runs.
- If true (COUNT > 5): The loop stops'

---

### Break

```break
for i in {1..10}
do 
    [ $i -eq 5 ] && break
    echo $1
done
```

#### Explaination

- for i in {1..10}: Iterates numbers 1 through 10.
- '[ $i -eq 5 ]' && break: Checks if $i equals 5.If true, break executes, instantly exiting the loop. No further iterations occur.
- 'echo $i': Prints the number (only reached if $i is not 5).

---

### Loop Over Files

```loop
for file in *.log
do
    echo "$file"
done
```

#### Explaination

- 'for file in *.log' : The shell expands this glob pattern into a list of all matching filenames (e.g., app.log, error.log, system.log)
- for file in ...: Iterates through each filename in that list, assigning it to the variable $file.
- echo "$file": Prints the filename. The quotes around "$file" are crucial to handle filenames containing spaces or special characters correctly.

---

### Loop Over Command Output

```loops_cmd
cat users.txt | while read line
do
    echo "$line"
done
```

---


## Task 4: Functions

### Defining a Function

```funtion
greet() {
    echo "Hello"
    }

```

### Calling Function

```call
greet
```

### Function argument

```arg
greet(){
    echo "Hello $1"
    }

greet Aditya
```

### Return values

#### Using return:

```Ret
check(){
return 0;
}
```

#### Using echo:

```ret
sum() { 
    echo $(($1 + $2))
    }

```

### Local Variable:

```local
greet(){
    local NAME="DevOps"
    echo $NAME
    }
```
## Task 5: Text Processing Commands

### grep

- The grep command searches text for patterns.

#### Search pattern:

```grep
grep "error" log.txt
```
- search for exact string "error"

#### ignore case:

```ign
grep -i "error" log.txt
```
- ignore case matches ("ERROR","error", Error)

#### Count matches:

```count
grep -c "error" log.txt
```
- print only the count of matching lines. not the line themselves.

#### Show line number

```line
grep -n "error" log.txt
```
- print the line number contaning 'error'.

#### invert match

```invert
grep -v "info" log.txt
```
- Shows the line that do not contain "info".

#### Extended regex

```extend
grep -E "error|warning" log.txt
```
- Allows logical OR to match multiple patterns.

---

### awk
The awk command is a powerful text processing tool that treats files as tables of rows and columns.

#### Print First Columns:

```first
awk '{print}' file.txt
```
-  Prints the first column of every line

#### Custom Seperator:

```sep
awk -F: '{print $1}' /etc/passwd
```
- Sets the field separator to a colon (:) using -F. This is essential for parsing files like /etc/passwd where columns aren't separated by spaces.

#### Pattern matching:

```pat
awk '/error/' log.txt
```
-  Prints only lines containing the pattern "error". You can add actions: awk '/error/ {print $1, $3}' log.txt prints specific columns only for matching lines

#### Begin and End:

```beg
awk 'BEGIN {print "Start"} {print $1} END {print "Done"}' file.txt
```
- BEGIN: Executes code before processing any lines (e.g., printing headers or initializing variables).
- END: Executes code after processing all lines (e.g., printing totals or footers).
- Main Block {print $1}: Executes for every line in the file.

---

### sed 
- The sed (Stream Editor) command is used for parsing and transforming text.

#### Replace text:

```replace
sed 's/old/new/g' file.txt
```
- Replaces all occurrences of "old" with "new" on every line.

#### Delete line:

```delete
sed '3d' file.txt
```
- Deletes line number 3

#### Edit in place:

```edit
sed -i 's/foo/bar/g' file.txt
```
-  Edits the file directly, saving changes to file.txt

---

### cut
- The cut command extracts specific sections (fields or characters) from each line of a file


#### Extract field:

```ext
cut -d',' -f1 file.csv
```
- prints column 1

---

### Sort
-The sort command arranges lines of text files

#### Alphabetically:

```alpha
sort file.txt
```
- Sorts lines alphabetically

#### Numerically:

```num
sort -n numbers.txt
```
- sorts by numerical values.

#### Reverse:

```rev
sort -r file.txt
```
- sort in reverse order.

#### Unique:

```unique
sort -u file.txt
```
- sorts and remove duplicate lines

---

### uniq
- The uniq command reports or filters out adjacent repeated lines

#### Remove Duplicates

```duplicate
uniq file.txt
```

#### Count duplicates

```count
uniq -c file.txt
```

---

### tr
- The tr (translate) command is used for character-level transformation or deletion from standard input.

#### Lowercase to Uppercase:

``ltou
tr 'a-z' 'A-Z'
``
-  Maps every character in the set a-z to the corresponding character in A-Z.

#### Deleted Character:

```Deleted
tr -d '\r'
```
- -d: Specifies delete mode.
- '\r': Targets the carriage return character. 

---

### wc

- The wc (word count) command displays the number of lines, words, and bytes in a file.

#### Basic Usage

```basic
wc file.txt
```
#### Specific flags

- wc -l file.txt: Counts lines (newline characters).
- wc -w file.txt: Counts words (sequences separated by whitespace).
- wc -c file.txt: Counts bytes (raw file size)

---

### head

- The head and tail commands are used to view the beginning and end of files.

#### Command:
```command
head file.txt 
head -n 20 file.txt
```

#### Application:
- head file.txt: Displays the first 10 lines by default.
- head -n 20 file.txt: Displays the first 20 lines (use -n to specify the count).

---

### tail

#### Command:
```command
tail file.txt 
tail -n 20 file.txt 
tail -f app.log
```

#### Application
- tail file.txt: Displays the last 10 lines by default.
- tail -n 20 file.txt: Displays the last 20 lines.
- tail -f app.log: Follows the file in real-time. It keeps the file open and prints new lines as they are appended.

---

## Task 6: Useful Patterns and One-Liners

### Delete files older then 30 days.

#### Script
```script
find . -type f -mtime +30 -delete
```

#### Explaination

- -type f: Targets only regular files (ignores directories).
- -mtime +30: Matches files modified more than 30 days ago.
- -delete: Removes the matched files.

### Count lines in all log files

```script
wc -l *.log
```

#### Explaination

- Displays the line count for each .log file and a total at the end

### Replace Text Across Multiple Files

```script
sed -i 's/old/new/g' *.conf
```

#### Explaination

- -i: Edits files in-place.
- *.conf: Applies the change to all .conf files in the current directory.

### Check If Service Is Running

```command
systemctl is-active nginx
```

#### Explaination
- Returns active if the service is running.
- Returns inactive or failed if it is not.
- Ideal for scripts because it outputs a simple status string and exit code (0 for active).

### Monitor Disk Usage

```command
df -h | awk '$5+0 > 80 {print}'
```

#### Explaination
- df -h: Shows disk usage in human-readable format.
- $5+0 > 80: Filters lines where the Usage % (column 5) is greater than 80%.
- The +0 ensures numeric comparison, ignoring the % symbol.
- Use Case: Quickly identify partitions that are nearly full.

### Parse CSV

```command
cut -d',' -f1 employees.csv
```

#### Explaination

- -d',': Sets the delimiter to a comma.
- -f1: Extracts the first field (column)

### Parse JSON

```command
jq '.name' file.json
```

#### Explaination
- Extracts the value associated with the key "name".
- Tip: Use jq -r '.name' to output raw strings without JSON quotes.

### Real-Time Error Monitoring

```command
tail -f app.log | grep --line-buffered ERROR
```

#### Explaination

- tail -f: Follows the log file as it grows.
- grep --line-buffered: Forces grep to output matches immediately (crucial for piping live streams).
- Use Case: Live debugging of applications by watching for specific error patterns.

---

## Task 7: Error Handling and Debugging

- In Bash scripting, exit codes are integers returned by commands to indicate their success or failure. 

### Exit Codes

- exit 0: Explicitly terminates the script with a success status.
- exit 1: Explicitly terminates the script with a failure status.
- echo $?: Prints the exit code of the last executed command.

### Strick Mode 

- set -e: Exits immediately if any command returns a non-zero status (fails).
- set -u: Treats unset variables as an error 
- set -o pipefail: Ensures a pipeline fails if any command in it fails 

- set -x: Enables trace mode. It prints every command and its arguments to stderr before executing it.
