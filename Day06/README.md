# Day 06 – Basic File Read/Write Operations

## 📌 Objective

The goal of Day 06 was to practice fundamental Linux file operations by creating, writing, appending, and reading a text file using basic shell commands. These operations are essential for working with configuration files, logs, scripts, and automation tasks in a DevOps environment.

---

## 📂 File Created

```text
notes.txt
```

---

## 🛠️ Commands Used

### 1. Create a New File

```bash
touch notes.txt
```

**Purpose:**
Creates an empty file named `notes.txt`.

**Observation:**
The file was created successfully and is ready to store data.

---

### 2. Write the First Line (Overwrite)

```bash
echo "Day 06 - Basic File Read/Write Practice" > notes.txt
```

**Purpose:**
Writes text to the file. If the file already contains data, it is overwritten.

**Observation:**
The file now contains the first line of text.

---

### 3. Append Additional Lines

```bash
echo "Learning Linux file operations." >> notes.txt
echo "Practicing file creation and editing." >> notes.txt
echo "Using output redirection operators." >> notes.txt
echo "Appending data without overwriting." >> notes.txt
echo "Working with Linux text files." >> notes.txt
echo "Reading file contents using cat." >> notes.txt
echo "Exploring head and tail commands." >> notes.txt
```

**Purpose:**
Appends new lines to the existing file while preserving previous content.

**Observation:**
Successfully added multiple lines without replacing the existing content.

---

### 4. Write and Display Using `tee`

```bash
echo "Displaying and writing output simultaneously." | tee -a notes.txt
```

**Purpose:**
Writes the output to the file while displaying it on the terminal.

**Observation:**
The text was displayed on the terminal and appended to the file at the same time.

---

## 📖 Reading the File

### Display the Entire File

```bash
cat notes.txt
```

**Purpose:**
Displays the complete contents of the file.

**Observation:**
Verified that all lines were written successfully.

---

### Display the First Two Lines

```bash
head -n 2 notes.txt
```

**Purpose:**
Displays the first two lines of the file.

**Observation:**
Useful for quickly checking the beginning of large files.

---

### Display the Last Two Lines

```bash
tail -n 2 notes.txt
```

**Purpose:**
Displays the last two lines of the file.

**Observation:**
Helpful for viewing the most recent entries in a file or log.

---

## 📄 Final Contents of `notes.txt`

```text
Day 06 - Basic File Read/Write Practice
Learning Linux file operations.
Practicing file creation and editing.
Using output redirection operators.
Appending data without overwriting.
Working with Linux text files.
Reading file contents using cat.
Exploring head and tail commands.
Displaying and writing output simultaneously.
```

---

## 📚 Key Learnings

- Learned how to create a file using `touch`.
- Understood the difference between `>` (overwrite) and `>>` (append).
- Practiced writing text to files using `echo`.
- Learned how to append data without losing existing content.
- Used `tee` to display output and write it to a file simultaneously.
- Explored different ways to read file contents using `cat`, `head`, and `tail`.
- Strengthened basic Linux file-handling skills that are commonly used in DevOps and system administration.

---

## 🚀 Real-World DevOps Use Cases

| Command | Common DevOps Use |
|----------|-------------------|
| `touch` | Create configuration files, log files, or placeholder files |
| `echo >` | Generate configuration or environment files |
| `echo >>` | Append logs, variables, or configuration entries |
| `tee` | Save command output while displaying it during automation scripts |
| `cat` | Read configuration files or application logs |
| `head` | Quickly inspect the beginning of configuration or log files |
| `tail` | Monitor the latest log entries for troubleshooting |

---

## 🎯 Conclusion

Day 06 focused on mastering basic file operations in Linux. Although these commands are simple, they are used daily by DevOps engineers for managing configuration files, maintaining logs, writing automation scripts, and troubleshooting systems. Building a strong understanding of these fundamentals is an important step toward becoming proficient in Linux and DevOps.
