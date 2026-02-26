---
description: Create or update a PR for the current branch. Analyzes diff against main, writes PR content in English, and requires user approval before any GitHub action.
---

# PR English

Creates or updates an English PR on `origin` (em3s/actionbase) only.

**Never create a PR on upstream (kakao/actionbase).** For upstream contributions, use `/patch-upstream`.

**Require user approval at every step before proceeding.**

## Workflow

### Step 1: Check for Existing PR

```bash
git branch --show-current
gh pr view --json number,title,body,url 2>/dev/null
```

Report to user:
- Current branch name
- **PR exists:** `#number`, title, URL
- **No PR:** "No existing PR for this branch"

**Proceed after user confirmation.**

### Step 2: Diff Analysis

```bash
git diff main...HEAD --stat
git diff main...HEAD
git log main...HEAD --oneline
```

### Step 3: Draft

Based on the diff, write the PR title and body **in English** following the style guide below.

**If PR already exists:** Use the title/body from Step 1 as a starting point. Keep accurate content, reflect new changes, remove outdated content.

**Do not create/update yet.** Show the draft to the user first.

**Wait for user approval or revision requests.**

### Step 4: Execute

Only execute after explicit user approval:

**Creating new PR:**
```bash
git push -u origin HEAD
gh pr create --title "..." --body "..."
```

**Updating existing PR:**
```bash
gh pr edit <number> --title "..." --body "..."
```

**Never include "Generated with Claude Code" or any AI attribution footer in the PR body.**

Return the PR URL when done.

---

## PR Style Guide

[criccomini (Chris Riccomini)](https://github.com/slatedb/slatedb/pulls?q=is%3Apr+author%3Acriccomini) — inspired by the SlateDB maintainer's style.

### Template

```markdown
## Summary
## Changes
## Reviewer Notes
## Checklist
```

### Summary — Why This PR Exists

- **First sentence**: What this PR does (one line)
- **Background**: Motivation, related issues, RFCs, previous PRs
- Bug fixes: describe the failure scenario in detail (timeline, race conditions, error logs)
- Performance: include before/after numbers (`10-20ms → 1.5ms`)
- Issue links: `Fixes #N` / `Closes #N`

### Changes — What Was Modified

- Bullet list, 3-6 items
- Start with verbs: Add, Fix, Replace, Remove, Improve
- Use backticks for filenames, function names, type names

### Reviewer Notes — Help the Reviewer

The most valuable section:

- **Alternatives considered**: Rejected approaches and why
- **Review order**: Suggest per-commit review when helpful
- **Caveats**: Slow tests, known limitations, future work
- **Honest tone**: Awkward parts, imperfections, deferred work
- **Trivial PRs**: `None.` is fine

### Checklist

```markdown
- [ ] Small, focused PR (under 500 lines excluding tests); or Draft with split plan
- [ ] Related issue linked or context added in description
- [ ] Self-reviewed the diff; commented on tricky parts
- [ ] Tests added/updated and passing locally
- [ ] Build and lint checks run
- [ ] Breaking changes documented with migration notes
- [ ] Performance impact reviewed; benchmarks added if needed
```

Be honest with the checklist — don't check items that don't apply.

### PR Size Guide

| PR Size | Summary | Changes | Reviewer Notes | Checklist |
|---------|---------|---------|----------------|-----------|
| Large (500+ lines) | Full context, alternatives, future goals | 4-6 items | Detailed | Full |
| Medium | Design trade-offs, rationale | 3-4 items | Key points | Full |
| Small (< 50 lines) | 2-3 sentences | 1-2 items | Omit or `None.` | Optional |

### Principles

1. **Explain "why this way" and "why not other ways"**
2. **Attach evidence** — error logs, benchmark numbers, GitHub Actions URLs
3. **Save reviewer time** — suggest review order, flag tricky parts, preemptively answer expected questions
4. **Be honest** — acknowledge limitations, incomplete parts, vibe-coded sections
5. **Say thanks** — `Thanks for reviewing!`
