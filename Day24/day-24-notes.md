# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## Task 1: Git merge

### Command used:

```command
git checkout main
git checkout -b feature-login
```
```command
echo "Login feature" >> app.txt
git add.
git commit -m "Added login page"
```
```command
echo "Login validation" >> app.txt
git add.
git commit -m "Added validation page"
```
```command
git checkout main
git merge feature-login
```

#### Observation:
- Git performed a Fast-Forward Merge because no new commits were added to main after creating feature-login.


### Feature Signup Branch

```command
git checkout -b feature-signup
```

```command
echo "Signup page" >> index.txt
git add.
git commit -m "Signup page added"
```

```command
echo "Invalid checkup" >> index.txt
git add.
git commit -m "Valid input page added"
```

```command
git checkout main
```

```command
echo "hello!!! I am aditya" >> hello.txt
git add.
git commit -m "Added Hello.txt"
```

```command
git merge feature-signup
```

#### Observation:
- Git created a Merge Commit because both branches had diverged.

### Answer in the notes:

#### 1. What is a Fast-forward merge ??
- A fast-forward merge happen when the target branch hasn't moved forward since the feature branch was created.
- git simply moves the branch pointer forward

#### 2. When does git create merge commit
- git creates merge commit when both the branches has unique commits and their histories have diverged.

#### 3. What is merge conflict ?
- A merge conflict occurs when git cannot automatically determine which changes to keep because the same part of the file is modified in different branch.

---

## Task 2: Git rebase

### Command used:

```command
git checkout -b feature-dashboard
```

```command
echo "Dashboard UI" >> dashboard.txt 
git add . 
git commit -m "Added dashboard UI"
```

```command
echo "Dashboard API" >> dashboard.txt
git add . 
git commit -m "Connected dashboard API"
```


