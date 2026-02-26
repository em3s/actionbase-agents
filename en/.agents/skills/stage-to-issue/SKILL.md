---
name: stage-to-issue
description: Record a side task discovered during implementation as a GitHub issue. Keeps focus on the current work. Use when a tangential task is found mid-implementation.
---

# Stage-to-Issue

When a new task is discovered during implementation, record it as a GitHub issue and return to current work.

## Usage

- `stage-to-issue Optimize CodeQL to run only on changed paths`
- `stage-to-issue Query engine needs cursor reset on schema change`

## Agent Signature

Include the CLI and model in the issue body.
Format: `<cli> (<model>)` -- e.g., `claude code (opus 4.6)`, `codex cli (o3)`

## Steps

1. **Gather context** -- identify the problem, motivation, and relevant details from the conversation
2. **Check related issues** -- if currently working on an issue/PR, include as reference
3. **Draft issue** -- write title and body in English
4. **Present draft** -- show the issue to the user
5. **Pause** -- wait for user confirmation
6. **Create** -- `gh issue create --title "<title>" --body "<body>"`
7. **Confirm** -- display created issue number and URL
8. **Return** -- resume current work

## Issue Body Template

```
## Problem
<What needs to be done and why>

## Context
<Relevant details gathered from current conversation>

## Related
- #<current-work-issue-number> discovered during this work (if applicable)

## Approach
<Suggested solution if available, otherwise omit this section>

---
Created by **<agent signature>**
```

## Rules

- Never create an issue without user confirmation
- Keep it concise — this is a side task, not a specification
- Include enough context for other sessions/agents to work independently
- Reference current issue in the Related section if applicable
- **Sign the issue** -- include agent signature at the bottom
- All output (title, body) in English
- Return to current work immediately after creation — do not start working on the new issue
