---
description: Analyze a new requirement, create an implementation plan, and publish it as a GitHub issue.
---

# Plan Command

Analyzes a new requirement and creates an implementation plan as a GitHub issue.

## Usage

- `/plan Add a new schema type for bookmarks`
- `/plan Refactor query engine to support cursor-based pagination`

## Agent Signature

Include the CLI and model in the issue body.
Format: `<cli> (<model>)` -- e.g., `claude code (opus 4.6)`, `opencode (codex 5.2)`

## Steps

1. **Analyze requirements** -- rephrase the request in clear terms
2. **Explore codebase** -- identify related files, dependencies, impact scope
3. **Create implementation plan** -- break into steps, identify risks
4. **Present draft issue** -- show to user
5. **Pause** -- wait for user confirmation
6. **Create issue** -- `gh issue create` to publish the GitHub issue
7. **Next steps** -- guide to `/implement <issue>` or end session

## Issue Body Template

```
## Summary
<What needs to be done and why>

## Analysis
<Affected files, dependencies, impact scope>

## Plan
- [ ] Step 1: <description>
- [ ] Step 2: <description>
- [ ] Step N: <description>

## Risks
- <Risk level>: <description>

## Estimated Complexity
<High/Medium/Low>

---
Created by **<agent signature>**
```

## Post-Session Flow

After issue creation, two paths:
- **Continue developing**: Start implementation immediately with `/implement <issue>`
- **Develop later**: End session, start with `/implement <issue>` next time

## Rules

- Never create an issue without user confirmation
- Issue must contain all context — other sessions/agents should be able to work independently
- Include codebase exploration results in the issue (related file paths, existing patterns)
- **Sign the issue** -- include agent signature at the bottom
- All output in English (code and code comments also in English)
