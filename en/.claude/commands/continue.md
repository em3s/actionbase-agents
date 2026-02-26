---
description: Resume development on an existing PR — restore context and continue from where it left off.
---

# Continue Command

Resumes the `/implement` workflow on an existing PR.

## Usage

- `/continue 42`
- `/continue https://github.com/kakao/actionbase/pull/42`

## Agent Signature

Include the CLI and model in all updates.
Format: `<cli> (<model>)` -- e.g., `claude code (opus 4.6)`, `opencode (codex 5.2)`

You may be a different agent than the one that started the PR. Sign your own work and preserve previous entries.

## Steps

1. **Fetch PR** -- `gh pr view <arg>` (body, status, branch)
2. **Checkout branch** -- `gh pr checkout <arg>`
3. **Read comments** -- `gh pr view <arg> --comments` to review history
4. **Read issue** -- extract `Closes #N` from PR body, `gh issue view <N>`
5. **Assess progress** -- identify completed `[x]` and pending `[ ]` items, last review round number, agents that worked on it
6. **Present status** -- show completed items, responsible agents, and next tasks to the user
7. **Pause** -- wait for user confirmation
8. **Resume** -- proceed with the next pending item following `/implement` steps 5-10, signing completed items

## Rules

- Never proceed without user confirmation
- Follow all `/implement` rules (including agent signatures and history preservation)
- Continue using the review round numbering from where it left off
- **Sign your work** -- step completions, review comments, PR body updates
- **Preserve history** -- never delete another agent's entries
- All output in English (code and code comments also in English)
