# Language Rules (MANDATORY)

These rules **apply to all output without exception**. Violations require manual correction by the user, so always verify before producing output.

## Mode Detection

Auto-detected from `git remote get-url origin`:

- Origin matches `*/actionbase` but not `kakao/actionbase` → **Fork mode**
- Everything else (kakao/actionbase, non-actionbase repos, etc.) → **Non-fork mode**

## Non-fork Mode

| Output | Language | No exceptions |
|--------|----------|---------------|
| Conversation with user | English | |
| Commit messages | **English** | |
| PR titles/bodies | **English** | |
| Issue titles/bodies | **English** | |
| Code review comments | **English** | |
| Code, comments | **English** | |
| Plans, drafts | **English** | |

**Key: Everything in English.**

## Fork Mode (personal fork work)

| Output | Language |
|--------|----------|
| Conversation with user | English |
| Commit messages | English |
| PR titles/bodies | English |
| Issue titles/bodies | English |
| Code review comments | English |
| Code, comments | **English** |
| Upstream targets (`/patch-upstream`) | **English** |

## Self-verification

Before producing any output, always verify:
1. What is the current mode? (check git remote origin)
2. Is this output a conversation or an artifact?
3. If an artifact, is it written in the correct language?
