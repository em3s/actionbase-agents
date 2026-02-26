---
name: implement
description: Implement a GitHub issue — create PR, code, build, review, iterate. Use when given an issue number or URL to implement.
---

# Implement

Takes an issue and implements it. Branch → PR → implement → build → review → iterate.

## Usage

- `implement 185`
- `implement https://github.com/kakao/actionbase/issues/185`

## Agent Signature

All work must include the performing agent and model.
Format: `<cli> (<model>)` -- e.g., `claude code (opus 4.6)`, `codex cli (o3)`

Identify your CLI and model at session start and use them consistently.

## Steps

1. **Fetch** -- `gh issue view <arg>` (check issue body for Plan)
2. **Branch** -- create `feat/issue-<number>-<short-desc>` from current branch
3. **Empty commit + PR** -- use template below to write the plan in the PR body
4. **Pause** -- wait for user confirmation
5. **Implement** -- code each step, commit, push, and check `[x]` in PR body
6. **Build + Test** -- run build and tests to verify
7. **Review** -- run `code-review`, present results to user
8. **Comment** -- record in PR comment as `## Review Round N`
9. **Fix** -- apply agreed-upon changes, commit, push
10. **Iterate** -- repeat steps 6-9 until no CRITICAL/HIGH issues remain

## PR Body Template

```
## Summary
<description>

Closes #<number>

## Plan
Created by **<agent signature>**

- [ ] Step 1
- [ ] Step 2
- [ ] Step N

## Progress
<!-- Each agent only appends here. Never delete previous entries. -->
- [x] Step 1 — **<agent signature>** (commit abc1234)
```

## Review Comment Template

```
## Review Round N
by **<agent signature>**

### Findings and Fixes

| Severity | Issue | Status |
|----------|-------|--------|
| CRITICAL | <description> | Fixed: <details> |
| HIGH | <description> | Fixed / Not fixed: <reason> |
| WARNING | <description> | Fixed: <details> |
| SUGGESTION | <description> | Fixed / Skipped: <reason> |

### Result
All tests pass. No CRITICAL/HIGH issues.
```

Severity levels: CRITICAL > HIGH > WARNING > SUGGESTION.
Record all issues in the table, including skipped ones (marked as `Skipped: <reason>`).

## Rules

- Never proceed without user confirmation
- Keep commits small and focused
- Always update PR body with latest progress
- **Sign all work** -- PR creation, plan updates, step completions, review comments must include agent signature
- **Preserve history** -- never delete another agent's entries when updating PR body. Append only.
- Record all review discussions as PR comments with round numbers
- All output (PR title, body, commits, comments) in English (code and code comments also in English)
