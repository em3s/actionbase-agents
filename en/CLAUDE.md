# Actionbase Worker Agent

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[kakao/actionbase](https://github.com/kakao/actionbase) — A database serving large-scale user interactions (likes, views, follows). **Who** did **what** to **which target**.

**Tech Stack**: Kotlin, Spring WebFlux (reactive), HBase (storage), Kafka (CDC events)

## Build & Test

```bash
./gradlew build                    # Full build
./gradlew test                     # All tests
./gradlew :core:build              # Specific module
./gradlew build --stacktrace       # Debugging
```

## Architecture

```
Server (WebFlux) → Engine (bindings) → Core (model)
```

| Module | Purpose |
|--------|---------|
| `core` | Data models, encoding, validation |
| `engine` | Storage/Messaging bindings |
| `server` | Spring WebFlux API server |

Ecosystem: `cli/`, `website/`, `docker/`, `bin/`, `dev/`, `guides/` — tools and documentation.

## .claude/ Structure

- `agents/` — Delegated sub-agents (planner, architect, code-reviewer, security-reviewer, e2e-runner, refactor-cleaner)
- `commands/` — Slash commands (plan, implement, continue, stage-to-issue, code-review, pr-english, patch-upstream, bedtime, reset-worktree)
- `skills/` — Context skills (actionbase-concepts, v3-transition, strategic-compact, verification-loop, testing-guide)
- `rules/` — Always-on guidelines (security, coding style, testing, git workflow, performance, language, agents, environment)
- `codemaps/` — Per-module codemaps, shared from `shared/.claude/codemaps/` (architecture, core, engine, server, data)

## Key Commands

### Development Workflow
`/plan` → `/implement` → `/continue` → `/stage-to-issue` → `/code-review`

### Active Commands
- `/code-review` — Review recent changes
- `/pr-english` — Create/update an English PR
- `/patch-upstream` — Generate patch + English PR comment
- `/bedtime` — Find simple tasks to work on overnight

## Repository Policy

This Claude is a **working tool for English-speaking developers drafting and building**.

### Scope of Work
- **Auto-detected fork mode** — determined from `git remote get-url origin`
  - Fork mode: origin matches `*/actionbase` but not `kakao/actionbase`
  - Non-fork mode: everything else
- Fork mode: write freely to origin, approval required for everything else
- Non-fork mode: approval required for all writes
- Upstream contributions via manual process or `/patch-upstream`

### Language (MANDATORY — no exceptions)

**This rule applies to all output without exception. See `.claude/rules/language.md` for details.**

Mode is auto-detected from `git remote get-url origin`.

#### Non-fork mode (origin is `kakao/actionbase` or not an actionbase repo)
- **Everything in English.**
- Conversation, commits, PRs, issues, reviews, code, drafts — all English

#### Fork mode (origin matches `*/actionbase` but not `kakao/actionbase`)
- **Conversation: English** — all dialogue, explanations, questions with the user
- **Fork artifacts: English** — issues, PRs, commit messages, reviews, plans
- **Always English:** code, code comments, upstream-targeted artifacts (`/patch-upstream`)

## Development Notes

- **Plan before coding** — understand requirements first
- **Write tests first** — TDD for new features
- **Review after coding** — verify security and quality
- **Commit often** — small, focused commits
- **Follow conventions** — consistency matters
