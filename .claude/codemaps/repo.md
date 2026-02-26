# Repository Codemap

## Overview

This repo delivers AI agent configuration for Actionbase projects.
It is organized by language, with shared (language-agnostic) config separated.

## File Map

### Root

```
CLAUDE.md              → Agent instructions for working on THIS repo
README.md              → Symlink to CLAUDE.md (GitHub renders it)
install.sh             → Public installer (curl one-liner)
                         - Downloads tarball from GitHub
                         - Interactive language menu (/dev/tty)
                         - --lang flag for non-interactive use
                         - Copies lang-specific + shared files to target project
```

### Language Packs (`ko/`, `en/`)

Each language pack is a complete, standalone set of agent config.
When installed to a target project, `<lang>/CLAUDE.md` → `./CLAUDE.md`
and `<lang>/.claude/*` → `./.claude/*`.

```
<lang>/
  CLAUDE.md              → Main agent instructions (project overview, architecture, workflows)
  .claude/
    agents/              → Sub-agent profiles
      architect.md         System design specialist
      code-reviewer.md     Code quality & security review
      e2e-runner.md        Integration testing
      planner.md           Planning & decomposition
      refactor-cleaner.md  Code cleanup
      security-reviewer.md Security-focused review

    codemaps/            → Architecture docs (target project modules)
      architecture.md      High-level architecture
      core.md              Core module (models, encoding)
      data.md              Data layer (storage, HBase)
      engine.md            Engine module (storage/messaging bindings)
      server.md            Server module (API endpoints)

    commands/            → Slash commands (agent workflows)
      plan.md              /plan — analyze requirement → GitHub issue
      implement.md         /implement — issue → branch → PR → code
      continue.md          /continue — resume existing PR
      code-review.md       /code-review — review recent changes
      pr-korean.md         /pr-korean — create Korean PR (ko only)
      patch-upstream.md    /patch-upstream — generate patch for upstream
      stage-to-issue.md    /stage-to-issue — side work → issue
      bedtime.md           /bedtime — find overnight tasks
      reset-worktree.md    /reset-worktree — clean git worktree
      update-codemaps.md   /update-codemaps — refresh architecture docs

    rules/               → Coding conventions and policies
      agents.md            Worker agent responsibilities & lifecycle
      coding-style.md      Kotlin/Java patterns, file limits, CQRS
      environment.md       macOS paths, directory structure
      git-workflow.md      Branch naming, commit format
      performance.md       Storage, messaging, WebFlux optimization
      security.md          Secret handling, OWASP checklist

    skills/              → Domain knowledge modules
      actionbase-concepts/ Core concepts (Schema, Mutation, Query, Datastore)
      strategic-compact/   Context compaction guidance
      testing-guide/       Testing patterns, @ObjectSource
      v3-transition/       V2→V3 engine migration
      verification-loop/   Build/test/security/diff validation
```

### Shared Config (`shared/`)

Language-agnostic configuration applied regardless of language selection.

```
shared/
  .claude/
    settings.json        → Tool permissions (Bash, Read, Write, Edit, etc.)
                           Pre-tool hooks: secret detection, build advisory, guard-repo
                           Post-tool hooks: spotless advisory, println detection
                           Stop hook: debug statement reminder

    hooks/
      guard-repo.sh      → Repository scope enforcement
                           Blocks gh commands targeting non-em3s/actionbase repos
                           Blocks git push to non-origin remotes
```

## Data Flow: install.sh

```
User runs curl one-liner
  → Downloads install.sh from GitHub raw
  → Script downloads repo tarball (public archive URL)
  → Extracts to temp directory
  → Reads --lang flag or prompts interactive selection
  → Copies <lang>/CLAUDE.md → ./CLAUDE.md
  → Copies <lang>/.claude/{agents,codemaps,commands,rules,skills} → ./.claude/
  → Copies shared/.claude/settings.json → ./.claude/settings.json
  → Copies shared/.claude/hooks/ → ./.claude/hooks/
  → Creates .claude/settings.local.json if absent
  → Cleans up temp directory
```
