# actionbase-agents

AI agent configuration for [Actionbase](https://github.com/em3s/actionbase) — a large-scale user interaction database (likes, views, follows).

Supports **Claude Code** and **Codex (OpenAI)**.

## Quick Install

Run from your actionbase project root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh)
```

Non-interactive:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh) --lang ko
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh) --lang ko --platform both
```

## Structure

```
ko/                         # Korean language pack
  CLAUDE.md                 #   Claude Code agent instructions
  AGENTS.md                 #   Codex agent instructions (CLAUDE.md + rules inlined)
  .claude/                  #   Claude Code config
    agents/                 #     Sub-agent profiles (6)
    commands/               #     Slash commands: /plan, /implement, /code-review, etc. (9)
    rules/                  #     Coding style, git workflow, security, performance, language (7)
    skills/                 #     Domain knowledge: concepts, testing, v3 transition (5)
  .codex/                   #   Codex config overlay
    config.toml             #     Language-specific overrides
  .agents/                  #   Codex skills (shared format with Claude)
    skills/                 #     Domain (5) + workflow (9) + codemaps (1) = 15 skills

en/                         # English language pack (same structure as ko/)

shared/                     # Language-agnostic config
  .claude/                  #   Claude Code shared config
    settings.json           #     Tool permissions, pre/post hooks, advisories
    setup.sh                #     Interactive local setup (upstream repo, git remotes)
    hooks/
      guard-repo.sh         #     Write guard + language enforcement (auto-detects fork mode)
    codemaps/               #     Architecture docs per module, English only (5)
  .codex/                   #   Codex shared config
    config.toml             #     Base Codex settings (model, sandbox, approval)
    agents/                 #     Agent TOML definitions (6)

.claude/
  commands/                 # Admin slash commands (5)

install.sh                  # curl one-liner installer with language + platform selection
```

## Working on This Repo

### Language policy

- Repo communication (commits, PRs, README, CLAUDE.md): **English**
- Agent config content (`ko/`, `en/`): respective language

### Adding a new language

1. Create `<lang>/CLAUDE.md` and `<lang>/.claude/` with translated config
2. Create `<lang>/AGENTS.md` and `<lang>/.agents/skills/` for Codex support
3. Create `<lang>/.codex/config.toml` for language-specific Codex overrides
4. Update `install.sh` language validation (`case` statement)
5. Update README language table

### Translation sync

When modifying agent config in one language pack:
- Structural changes (new command, renamed file) must be reflected in all language packs
- Content changes (rule updates, new skills) should be synced eventually
- `shared/` changes apply to all languages automatically

### Key files

| File | Purpose |
|------|---------|
| `install.sh` | Public curl-based installer. Downloads tarball, selects language and platform, copies files. |
| **Shared — Claude Code** | |
| `shared/.claude/settings.json` | Tool permissions and hook config — shared across all languages. |
| `shared/.claude/setup.sh` | Interactive setup script. Configures upstream repo and git remotes. |
| `shared/.claude/hooks/guard-repo.sh` | Guards writes based on auto-detected fork mode (from git remote origin). |
| `shared/.claude/codemaps/*.md` | Architecture documentation per Actionbase module (English only). |
| **Shared — Codex** | |
| `shared/.codex/config.toml` | Base Codex settings (model, sandbox, approval). |
| `shared/.codex/agents/*.toml` | Agent TOML definitions for Codex multi-agent (6 agents). |
| **Language pack — Claude Code** | |
| `<lang>/CLAUDE.md` | Claude Code agent instructions. |
| `<lang>/.claude/commands/*.md` | Slash commands defining agent workflows. |
| `<lang>/.claude/rules/*.md` | Coding conventions, git workflow, security policies. |
| `<lang>/.claude/skills/*/SKILL.md` | Domain knowledge modules (Claude skills). |
| `<lang>/.claude/agents/*.md` | Sub-agent profiles (architect, code-reviewer, planner, etc.). |
| **Language pack — Codex** | |
| `<lang>/AGENTS.md` | Codex agent instructions (CLAUDE.md + rules inlined, <32KB). |
| `<lang>/.codex/config.toml` | Language-specific Codex config overrides. |
| `<lang>/.agents/skills/*/SKILL.md` | Codex skills — domain (5) + workflow (9) + codemaps (1). |

## Admin Commands

Slash commands for managing this repo (defined in `.claude/commands/`):

| Command | Purpose |
|---------|---------|
| `/sync-check` | Check structural consistency across language packs |
| `/validate [lang]` | Validate language pack structure and file formats |
| `/add-language <lang>` | Scaffold a new language pack from an existing one |
| `/release [version]` | Pre-release checklist: validate, sync-check, and tag |
| `/update-codemaps` | Generate or update architecture codemaps in `shared/.claude/codemaps/` |

## Runtime Modes

Determined automatically from `git remote get-url origin`:

| Mode | Condition | Conversation | Artifacts (commits, PRs, issues) | Code & comments |
|------|-----------|-------------|----------------------------------|-----------------|
| **Fork** | origin matches `*/actionbase` but not `kakao/actionbase` | Language pack language | Language pack language | Always English |
| **Non-fork** | everything else (kakao/actionbase, non-actionbase repos) | Language pack language | Always English | Always English |

- **Fork mode**: Working on a personal fork of actionbase. Origin writes are free; writes elsewhere require confirmation. Fork-local artifacts follow the language pack; upstream-targeted artifacts (`/patch-upstream`) are always English.
- **Non-fork mode**: Working directly on upstream or a non-actionbase repo. All writes require confirmation. All artifacts are in English regardless of language pack.

Each language pack's `CLAUDE.md` must include these rules under a `### Language` / `### 언어` section.

## Available Languages

| Code | Status |
|------|--------|
| `ko` | Available |
| `en` | Available |

## License

MIT
