# actionbase-agents

AI agent configuration for [Actionbase](https://github.com/em3s/actionbase) — a large-scale user interaction database (likes, views, follows).

Currently supports **Claude Code**. Other agent platforms are planned.

## Quick Install

Run from your actionbase project root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh)
```

Non-interactive:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh) --lang ko
```

## Structure

```
ko/                         # Korean language pack
  CLAUDE.md                 #   Agent instructions
  .claude/
    agents/                 #   Sub-agent profiles (6)
    commands/               #   Slash commands: /plan, /implement, /code-review, etc. (10)
    rules/                  #   Coding style, git workflow, security, performance (6)
    skills/                 #   Domain knowledge: concepts, testing, v3 transition (5)

en/                         # English language pack (planned)
  CLAUDE.md
  .claude/
    agents/  commands/  rules/  skills/

shared/                     # Language-agnostic config
  .claude/
    settings.json           #   Tool permissions, pre/post hooks, advisories
    hooks/
      guard-repo.sh         #   Repository scope enforcement (em3s/actionbase only)
    codemaps/               #   Architecture docs per module, English only (5)

.claude/
  commands/                 # Admin slash commands (5)

install.sh                  # curl one-liner installer with language selection
```

## Working on This Repo

### Language policy

- Repo communication (commits, PRs, README, CLAUDE.md): **English**
- Agent config content (`ko/`, `en/`): respective language

### Adding a new language

1. Create `<lang>/CLAUDE.md` and `<lang>/.claude/` with translated config
2. Update `install.sh` language validation (`case` statement)
3. Update README language table

### Translation sync

When modifying agent config in one language pack:
- Structural changes (new command, renamed file) must be reflected in all language packs
- Content changes (rule updates, new skills) should be synced eventually
- `shared/` changes apply to all languages automatically

### Key files

| File | Purpose |
|------|---------|
| `install.sh` | Public curl-based installer. Downloads tarball, selects language, copies files. |
| `shared/.claude/settings.json` | Tool permissions and hook config — shared across all languages. |
| `shared/.claude/hooks/guard-repo.sh` | Blocks writes outside `em3s/actionbase` scope. |
| `ko/CLAUDE.md` | Korean agent instructions for Actionbase development. |
| `ko/.claude/commands/*.md` | Slash commands defining agent workflows. |
| `ko/.claude/rules/*.md` | Coding conventions, git workflow, security policies. |
| `ko/.claude/skills/*/SKILL.md` | Domain knowledge modules the agent can reference. |
| `shared/.claude/codemaps/*.md` | Architecture documentation per Actionbase module (English only). |
| `ko/.claude/agents/*.md` | Sub-agent profiles (architect, code-reviewer, planner, etc.). |

## Admin Commands

Slash commands for managing this repo (defined in `.claude/commands/`):

| Command | Purpose |
|---------|---------|
| `/sync-check` | Check structural consistency across language packs |
| `/validate [lang]` | Validate language pack structure and file formats |
| `/add-language <lang>` | Scaffold a new language pack from an existing one |
| `/release [version]` | Pre-release checklist: validate, sync-check, and tag |
| `/update-codemaps` | Generate or update architecture codemaps in `shared/.claude/codemaps/` |

## Available Languages

| Code | Status |
|------|--------|
| `ko` | Available |
| `en` | Planned |

## License

MIT
