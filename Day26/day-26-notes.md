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


