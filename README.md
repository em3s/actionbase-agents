# actionbase-agents

AI agent configuration for [Actionbase](https://github.com/em3s/actionbase) — a large-scale user interaction database (likes, views, follows).

Currently supports **Claude Code**. Other agent platforms are planned.

## Quick Install

Run from your actionbase project root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh)
```

The installer will prompt you to select a language (Korean / English).

For non-interactive use:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh) --lang ko
```

## What Gets Installed

| Path | Description |
|------|-------------|
| `CLAUDE.md` | Agent instructions (project overview, architecture, workflows) |
| `.claude/agents/` | Sub-agent profiles (architect, code-reviewer, planner, etc.) |
| `.claude/codemaps/` | Architecture documentation for each module |
| `.claude/commands/` | Slash commands (`/plan`, `/implement`, `/code-review`, etc.) |
| `.claude/rules/` | Coding style, git workflow, security, and performance guidelines |
| `.claude/skills/` | Domain knowledge (concepts, testing, v3 transition) |
| `.claude/hooks/` | Safety guardrails (repository scope enforcement) |
| `.claude/settings.json` | Tool permissions and hook configuration |

## Structure

```
ko/                     # Korean config
  CLAUDE.md
  .claude/
    agents/  codemaps/  commands/  rules/  skills/

en/                     # English config (planned)
  CLAUDE.md
  .claude/
    agents/  codemaps/  commands/  rules/  skills/

shared/                 # Language-agnostic
  .claude/
    settings.json
    hooks/guard-repo.sh
```

## Available Languages

| Code | Status |
|------|--------|
| `ko` | Available |
| `en` | Planned |

## License

MIT
