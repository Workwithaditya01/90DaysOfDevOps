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

```command
git checkout main
```

```command
echo "Main Improvement" >> app.txt
git add . 
git commit -m "Main branch improvement
```

```command
git checkout feature-dashboard
git rebase main
```

#### Observation:
-   The branch commits were replayed on top of the latest main commit.

```command
git log --oneline --graph --all
```

- The history appeared linear and cleaner compared to merge.

### Answers:

#### 1.What does rebase actually do to your commits ?
- Rebase moves or replays commits from one branch onto another base commit.

#### 2.How is the history different from a merge ?
- rebase creates a clean linear history, while merge preserve branch history with merge commit.

#### 3.Why should you never rebase commits that have been pushed and shared with others?
- Rebasing changes commit hashes and rewrites history, which can cause conflicts for collaborators.

#### 4.When would you use rebase vs merge?
- Use Rebase to maintain a clean linear history before merging.
- Use Merge when you want to preserve branch history.

---

## Task 3: Squash Merge vs Merge Commit

### Squash merge

```command
git checkout -b feature-profile
```

```command
git commit -m "Profile UI"
git commit -m "Fixed typo"
git commit -m "Updated styling" 
git commit -m "Added validation"
```

```command
git checkout main
git merge --squash feature-profile
git commit -m "Added profile feature"
```

#### Observation
- Only one commit was added to main.

### Regular merge

```command
git checkout -b feature-settings
```

```command
git commit -m "Settings UI"
git commit -m "Added preferences" 
git commit -m "Added notifications"
```

```command
git checkout main
git merge feature-settings
```

#### Observation
- All commits from the branch appeared in history.

---

