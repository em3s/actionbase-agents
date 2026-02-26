# Actionbase Agent (English)

## Installation

From the actionbase project root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh) --lang en
```

## Configuration

`setup.sh` runs automatically during installation. To reconfigure later:

```bash
bash .claude/setup.sh
```

Settings are stored in `.claude/settings.local.json`.

## Usage Scenarios

### A. Fork Mode (working on a personal fork)

Auto-detected when origin matches `*/actionbase` but not `kakao/actionbase`.

```
git remote -v
  origin    → em3s/actionbase        (fetch/push)
  upstream  → kakao/actionbase       (fetch only, push = no_push)
```

| Item | Behavior |
|------|----------|
| Conversation | English |
| Commits, PRs, issues | English |
| Code, comments | English |
| Upstream contributions (`/patch-upstream`) | English |
| Origin writes (push, PR, etc.) | Allowed |
| Other writes | Approval required |

### B. Non-fork Mode (upstream or other repos)

Everything else (kakao/actionbase, non-actionbase repos, etc.).

```
git remote -v
  origin    → kakao/actionbase       (fetch/push)
```

| Item | Behavior |
|------|----------|
| Conversation | English |
| Commits, PRs, issues | English |
| Code, comments | English |
| All writes | Approval required |
