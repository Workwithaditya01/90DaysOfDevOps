# Day 23 - Git Braching & Working with GitHub

## Task 1:- Understanding Branches 

### 1. What is branch in Git?
- A branch is a independent line of development in git. it allows developer to work on new features, bug fixes, or experiments without effecting the main project code.

### 2. Why do we use branches instead of committing everything in main ??
- Branches helps keep the main branches stable and production-ready.
- Developer can safely test new changes in separate branches and merge them into main branch after verification.

### 3. what is Head in git ?
- Head is the pointer that refers to the current branch and latest commit you are working on.

### 4. what happens to your files when you switch branches ??
- When switching branches, Git updates your working directory to match the files and commits stored in the selected branch.

---
 
## Task 2:- Branching Commands - Hands-on 

### Lisiting all branches

#### Command:
```command
git branch 
```

### Create a new Branch called feature-1

#### Command:
```command
git branch feature-1
```

### Switching to the feature-1 branche

#### Command
```command
git checkout feature-1
```

#### Or

```command
git switch feature-1
```

### create a new branch and switch in one command

#### Command
```command
git checkout -b feature-2
```
#### Or
```command
git switch -b feature-2
```

### Difference Between Switch and Checkout

#### git switch
- It is a modern Command
- Designed only for branch switching
- easier and safer to use

#### git checkout
- older command
- used for branch switching 
- can restore files
- perform multiple task

### make a commit on feature-1

#### Command:
```command
git switch feature-1

echo "Feature 1 changes" >> feature.txt

git add feature.txt

git commit -m "Added feature.txt"

```

### Verify commit does not exist on main

#### Switch back:
```command
git switch main
```

#### Check Files 
```command
ls
```

### Delete a branch
```command
git branch -d feature-2
```

---

## Task 3: Push to GitHub

### Create a Git repository

- 1. Login to GitHub
- 2. Click new repository
- 3. Repository name: devops-git-practice
- 4. Do NOT initialize with README.
- 5. Click Create Repository.

### Connect Local Repository

#### Command
```command
git remote add origin https://github.com/USERNAME/devops-git-practice.git
```

##### Verify
```command
git remote -v
```

### Push main branch

```command
git push -u origin main
```

### Push feature branch

```command
git push -origin feature-1
```

### Verify on github

- Open the repository on GitHub and check the Branches section. Both main and feature-1 should be visible.

### Difference between origin and upsteam

| Origin | Upstream |
|--------|----------|
| Your fork/repository | Original repository |
| Default push target | source repository |
| usually write access | usually read-only |

---

## Task 4: Pull from GitHub

### Make a change on GitHub

- Open a file on GitHub.
- Click Edit.
- Add text.
- Commit changes.

### Pull changes locally

```command
git pull origin main
```

#### Difference between git fetch and git pull

| git fetch	| git pull |
|-----------|----------|
| Downloads changes	| Downloads + merges |
| Safe inspection | Direct update |
| No automatic merge | Automatic merge |

---

## Task 5: Clone vs Fork

### Clone a Repository
```command
git clone https://github.com/TrainWithShubham/python-for-devops
```

### Fork a Repository

- 1. Open the Repository on GitHub.
- 2. Click fork.
- 3. GitHub creates a copy under your account.
- 4. clone your fork

### Difference between clone and fork

#### Clone
- creates a local copy of a repository on your machine.

#### fork 
- creates a copy of a repository on github under your account

### When you would clone and fork

#### Clone
- Working on your own repositories
- You already have write access
#### Fork
- Contributing to open-source projects
- You do not have write access

### Keeping a Fork Updated

#### Add upstream remote
```command
$ git remote add upstream https://github.com/TrainWithShubham/python-for-devops
```

#### fetch latest changes
```command
git fetch upstream
```

---

## Key Takeaways
- Branches allow isolated development.
- HEAD points to the current commit.
- git switch is the modern branch-switching command.
- origin refers to your remote repository.
- upstream refers to the original repository.
- git fetch downloads changes only.
- git pull downloads and merges changes.
- Clone creates a local copy.
- Fork creates a GitHub copy under your account
