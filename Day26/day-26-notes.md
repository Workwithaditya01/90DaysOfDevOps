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


