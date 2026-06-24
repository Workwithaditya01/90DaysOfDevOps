# Day 25 – Git Reset vs Revert & Branching Strategies

## Task 1: Git Reset - Hands-On

### Initial Commit History

```command
git log --oneline
```
#### Output

```output
C
B
A
```

#### 1. git reset --soft HEAD~1

```command
git reset --soft HEAD~1
```

#### Observation:

- Commit C is removed from git history.
- changes from commit C remain staged.
- files stay unchanged.
- Ready to recommit.

#### Checking:

```command
git status
```
- Analyse the output the output should be 'Changes to be commmitted'

#### 2. git reset --mixed HEAD~1

- After Recommitting C

```command
git reset --mixed HEAD~1
```

#### Observation

- Commit C is removed.
- changes remain in working directory.
- changes become unstaged.

#### Checking 

```command
git status
```
- Analyse the output the output should be 'Changes not staged for commit'

#### 3. git reset --hard HEAD~1

- After recommitting C

```command
git reset --hard HEAD~1
```

#### Observation

- Commit C is removed.
- Changes are Deleted from working directory
- staging area is cleard 
- working directory matches previous commit

#### Checking

```command
git status
```
- Analyse the output the output should be 'nothing to commit, working tree clean'

### Answers

#### Differenct between --soft, --mixed and --hard:

| Option | Commit Removed | Changes Staged | Changes Kept |
|--------|----------------|----------------|--------------|
| --soft | Yes | Yes | Yes |
| --mixed | Yes | No | Yes |
| --hard | Yes | No | No |

#### Which one is destructive?
```command
git reset --hard HEAD~1
```
- deletes commit and local changes permanently.
- can cause data loss of changes are not backed up.

#### When would you use Each ?
```commadn
--soft
```
- You want to modify the last commit
- combine multiple commits.

```command
--mixed
```
- Undo Commit but keep the file changes
- reorganize staging area

```command
--head
```

- Discard unwanted local changes completely.
- return repository to a clean state.

#### Should you use git reset on Pushed Commits?

- Generally no.
- rewriting commit history, causes conflicts for teammates.
- Use is when working alone and everyone agress to rewrite history.

----

## Task 2: Git revert - Hands on

### Initial Commits:
```commits
Z
X
Y
```

#### Revert Commit Y
```command
git revert <commit id of Y>
```
#### Git creates a new Commit

Revert "Y"

#### New History

```history
Revert Y
Z
X 
Y
```

### Observation

#### Is Commit Y still in History ?
- yes 
- commit y remains in history
- git adds a new commit that reverses Y's Channges.

### Answers

#### How is git revert different from git reset?
- git reset
- moves branch pointer backwards
- can remove commits from history 

- git revert
- creates a new commit
- preserves existing history.

#### Why is Revert safer for shared branches?
- History is not rewritten
- exisiting commits remain unchanged
- team members don't face force -puch issues.

#### when would you use revert and reset?

##### using revert
- shared branches
- production code
- public repository

#### Using reset
- local commits
- cleaning commit history
- before pushing

---

## Task 3: Reset vs Revert Summary

| Feature | git reset | git revert |
|---------|-----------|------------|
| What it does | Moves HEAD backward | creates inverse commit |
| Removes commit from history | Yes | No |
| Safe for shared branches | No | Yes |
| rewrites history | Yes | No |
| Requires force push | yes | No |
| When to use | Local cleanup | Undo Pushed Commits |

---

## Task 4: Branching Strategies

### 1. GitFlow

#### How it works

##### Uses multiple long-lived Branches

- main
- develop
- feature
- release
- hotflix

#### Flow

```flow
feature
   |
develop
   |
release
   |
  main
  ^
  hotflix
```

#### Used By

- Enterprise projects
- large release cycles

#### Pros

- Structured workflow
- easy release management
- Support parellel development

#### Cons

- Complex
- many branches
- slower release

### 2. GitHub Flow

#### How it works
- Single main branch with feature branches.

#### Flow
```flow
main 
   |
feature-1
   | 
Pull Request 
   | 
Merge to main
```

#### Used by

- SaaS products
- Startups
- Open source projects

#### Pros

- simple
- fast deployment
- easy collaboration

#### Cons

- requires strong testing
- less release control

### 3. Trunk-based Development

#### How it works
- Developers integrate frequently into main branch

#### Flow
```flow
main
  |\
  | feature
  |
  merge Quickly
  |
main
```

#### Used by

- Google 
- Meta
- High-performing DevOps Teams

#### Pros-

- Continuous Integration
- Fast Delivery
- reduces Merge Conflicts

#### Cons

- requires excellent automation
- strong testing pipeline needed

### Answers

#### Which Strategy for a Startup Shipping Fast?

- GitHub Flow 
- Simple
- Fast releases
- Minimal overhead

#### Which Strategy for a Large Team with Scheduled Releases?

- GitFlow
- Better release management
- Separate release and hotfix branches
- Supports large teams

#### Which Strategy Does an Open Source Project Use?

- Kubernetes
- Feature branch
- Pull Request
- Code Review
- Merge into main branch





































