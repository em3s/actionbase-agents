---
description: Pull upstream main, reset worktree to latest main, and push to origin.
---

# Reset Worktree

Pulls main from upstream to get the latest state, resets the current worktree to main, and pushes to origin.
Use when cleaning up a work branch and starting fresh.

## Workflow

### Step 1: Check Current State

```bash
git branch --show-current
git status --short
git log --oneline -3
```

Report to user:
- Current branch name
- Whether there are uncommitted changes
- Last 3 commits

**If there are uncommitted changes, warn the user and get confirmation. If the user chooses to proceed, continue to the next step.**

### Step 2: Pull upstream main

```bash
git fetch upstream main
git checkout main
git merge upstream/main --ff-only
```

- If fast-forward fails, notify the user and **stop**.

### Step 3: Push to origin

```bash
git push origin main
```

### Step 4: Reset worktree branch (if applicable)

If on a non-main branch in Step 1:

```bash
git checkout <original-branch>
git reset --hard main
```

If already on main, skip this step.

### Step 5: Summary

After completion, report:
- Latest commit on main (hash + message)
- Whether origin push succeeded
- Current branch status
