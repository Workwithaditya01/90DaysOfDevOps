# Day 06 – Linux Fundamentals: Read and Write Text Files

## Step 1: Create the file

### Command:

```bash
touch notes.txt
```

### Purpose:

```text
Creates an empty file named notes.txt
```
---

## Step 2: Write the first line using >

### Command:

```bash
echo "Day 06 - File Operations Practice" > notes.txt
```

### Purpose

```text
- echo prints text.
- > writes text to a file.
- If the file already contains data, > overwrites it.
```

---

### Step 3: Append more lines using >>

### Command:

```bash
echo "Learning Linux file handling." >> notes.txt
echo "Practicing file read and write operations." >> notes.txt
echo "Using redirection operators." >> notes.txt
echo "Understanding append functionality." >> notes.txt
echo "Exploring Linux commands." >> notes.txt
echo "Reading files with cat." >> notes.txt
echo "Viewing file sections with head." >> notes.txt
```

### Purpose:

```text
>> appends content without deleting existing data
```
---

## Step 4: Use tee

### Command:

```bash
echo "Viewing and writing simultaneously." | tee -a notes.txt
```

### Purpose:

```text
- Displays the text on the terminal.
- Appends the text to the file.
- -a means append.
```
---

## Step 5: Add one final line

### Command:

```bash
echo "Day 06 practice completed." >> notes.txt
```

### Purpose:

```text
Now the file contains about 9–10 lines.
```

---

## Read Entire File

### Command:

```bash
cat notes.txt
```

### Output

```text
Day 06 - File Operations Practice
Learning Linux file handling.
Practicing file read and write operations.
Using redirection operators.
Understanding append functionality.
Exploring Linux commands.
Reading files with cat.
Viewing file sections with head.
Viewing and writing simultaneously.
Viewing and writing simultaneously.
Day 06 practice completed.
```

## Read Beginning of File

### Command:

```bash
head -n 2 notes.txt
```

### Output:

```text
Day 06 - File Operations Practice
Learning Linux file handling.
```

## Read the Last 2 Lines

### Command:

```bash
tail -n 2 notes.txt
```

```text
Viewing and writing simultaneously.
Day 06 practice completed.
```
---

## Key Leaning:

- > overwrites file content.
- >> appends content.
- cat displays the full file.
- head reads from the beginning.
- tail reads from the end.
- tee writes and displays output simultaneously.


