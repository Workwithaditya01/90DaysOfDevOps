# Day 26: GitHub CLI: Manage GitHub From Your Terminal

### What is GitHub CLI ?
- GitHub CLI(gh) is an official command-line tool that allows developers to interact with github directly from the terminal without opening browser.

---

## Task 1: Install and Authenticate

### Install GitHub CLI

#### Windows 

```windows
winget install --id GitHub.cli
```

#### Verify Installation

```verify
gh --version
```

#### Authenticate

```auth
gh auth login
```

#### Check Current Account

```status
gh auth status
```

#### Observation

- Successfully authenticated GitHub Account and verified active user using

````verify
ght auth status
````

---

## Task 2: Working With Repository

### Create repository

```repo
gh repo create test-gh-cli --public --add-readme
```

### Clone repository

```clone
gh repo clone Workwithaditya01/90DaysOfDevOps
```

### View Repository

```view
gh repo view Workwithaditya01/90DaysOfDevOps
```

### List repository

```list
gh repo list
```

### Open repository in browser

```open
gh repo view --web
```

### Delete Repository

```delete
gh repo delete test-gh-cli
```

#### Observation
- Repository lifecycle can be managed completely from terminal without opening GitHub website.

---

## Task 3: Issues

### Create Issue

```issue
gh issue create --title "Test Issue" --body "Created from GitHub CLI" --label bug
```

### List Open Issues

```list
gh issue list
```

### View Specific Issue

```view
gh issue view 1
```

```view
gh issue view 2
```

### Close Specific issue

```close
gh issue close 1
```

---

## Task 4: Pull Request

### create Branch

```create
git checkout -b update-readme
```

### make Changes

```changes
git add .
git commit -m "Update Readme"
```

### Push Branch

```push
git push origin update-readme
```

### Create Pull Request

```pull
gh pr create --fill
```

### List Pull Request

```list
gh pr list
```

### View Pull Request

```view
gh pr view
```

### Merge Pull Request

```merge
gh pr merge
``` 

## Question : What merge method does gh pr merge support ?

### Merge Commit
```merge
gh pr merge --commit
```

### Squash merge
```squash
gh pr merge --squash
```

### Rebase merge
```merge
gh pr merge --rebase
```

## Question : How would you review someone else's PR using ph ?

### View PR:
```view
gh pr view 10
```

### Checkout PR Locally:
```checkout
gh pr checkout 10
```

### Approve
```approve
gh pr review 10 --approve
```

### Request Changes:
```request
gh pr review 10 --request-changes
```

### Commit:
```commit
gh pr review 10 --comment
```

---

