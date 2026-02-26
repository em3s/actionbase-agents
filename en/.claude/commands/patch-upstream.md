---
description: Generate a patch file + translate PR body to English and attach as PR comment. Requires an existing PR on origin.
---

# Patch Upstream

Generates a patch file from the current branch diff and translates the PR body to English, posting it as a comment on the PR.
Used for manual contribution to upstream (kakao/actionbase).

**Prerequisite: A PR must already exist on origin (created via `/pr-english`).**

## Workflow

### Step 1: Check PR and Read Body

```bash
gh pr view --json number,title,body,url 2>/dev/null
```

- **PR exists:** Confirm PR number and body, proceed.
- **PR doesn't exist:** Instruct "Create a PR first with `/pr-english`." and **stop**.

### Step 2: Analysis

```bash
git branch --show-current
git diff main...HEAD --stat
git log main...HEAD --oneline
```

Report to user:
- Current branch name
- Target PR: `#number`
- Changed files (stat)
- Commit count

**Proceed after user confirmation.**

### Step 3: Generate Patch

Generate a patch file from the diff against `main`. Exclude `.claude/` and `CLAUDE.md`.
Filename format: `em3s-actionbase-pr<number>.patch`:

```bash
git diff main...HEAD -- . ':!.claude' ':!CLAUDE.md' > /tmp/em3s-actionbase-pr<number>.patch
```

Report:
- Patch file path
- Patch size (line count)
- Included files

For commit-based patches:
```bash
git format-patch main...HEAD -- . ':!.claude' ':!CLAUDE.md' -o /tmp/em3s-actionbase-pr<number>/
```

### Step 4: English Summary and PR Comment

Prepare an English summary of the PR for upstream contribution.

**Translation principles:**
- Not a literal translation — adapt meaning so English-speaking developers understand naturally
- Clarify context-dependent statements, implicit meanings
- Use upstream project terminology for technical terms

Show the user the English version and get approval first.

If any adaptations were made, note them below the translation:

```
> Translation notes:
> - "original expression" → "English expression": reason for adaptation
```

After approval, post as PR comment:

```bash
gh pr comment <number> --body "$(cat <<'EOF'
## English Translation (for upstream contribution)

**Title:** <English title>

<Full English body>
EOF
)"
```

**Never include "Generated with Claude Code" or any AI attribution footer in the comment.**

### Step 5: Summary

After completion, provide:
1. Patch file path
2. PR comment URL (with English translation)
3. Reference commands:

```bash
# Apply patch in target repo
cd /path/to/kakao/actionbase
git apply /tmp/em3s-actionbase-pr<number>.patch

# For format-patch
git am /tmp/em3s-actionbase-pr<number>/*.patch
```
