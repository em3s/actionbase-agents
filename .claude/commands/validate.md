---
description: Validate a single language pack for completeness and correctness.
---

# Validate

Validate a language pack's structure, file format, and required content.

## Usage

`/validate [<lang-code>]`

- `<lang-code>` — language to validate (default: all detected languages)

Examples:
- `/validate ko`
- `/validate` (validates all)

## Checks

### 1. Directory structure
- Required directories exist: `agents/`, `commands/`, `rules/`, `skills/`
- No unexpected directories under `.claude/`

### 2. CLAUDE.md
- Exists at `<lang>/CLAUDE.md`
- Not empty
- Contains at least one `##` heading

### 2b. AGENTS.md (Codex)
- If `<lang>/AGENTS.md` exists:
  - Not empty
  - Under 32KB (Codex limit)
  - Contains at least one `##` heading

### 3. Commands
- Every `.md` file in `commands/` has YAML frontmatter with `description` field
- `description` is non-empty

### 4. Rules
- Every `.md` file in `rules/` is non-empty
- Contains at least one `#` heading

### 5. Skills
- Each subdirectory in `skills/` contains `SKILL.md`
- `SKILL.md` is non-empty

### 6. Agents
- Every `.md` file in `agents/` is non-empty
- Contains at least one `#` heading

### 7. Shared config
- `shared/.claude/settings.json` exists and is valid JSON
- `shared/.claude/hooks/guard-repo.sh` exists and is executable

### 7b. Shared Codex config
- If `shared/.codex/config.toml` exists, it is valid TOML
- Each `.toml` file in `shared/.codex/agents/` is valid TOML

### 8. Codex skills (if present)
- If `<lang>/.agents/skills/` exists:
  - Each subdirectory contains `SKILL.md`
  - Each `SKILL.md` has YAML frontmatter with `name` and `description` fields
  - Skill count matches expected (15: 5 domain + 9 workflow + 1 codemaps)

### 9. install.sh consistency
- Language code appears in `install.sh` case statement
- `LANG_DIRS` variable in `install.sh` matches actual subdirectory names used across language packs

## Report format

```
## Validation Report: ko

### Directory structure
✅ agents/ (6 files)
✅ commands/ (10 files)
✅ rules/ (6 files)
✅ skills/ (5 skills)

### CLAUDE.md
✅ Exists, 4 sections

### Commands frontmatter
✅ All 10 commands have description

### Rules format
✅ All 6 rules valid

### Skills structure
✅ All 5 skills have SKILL.md

### Agents format
✅ All 6 agents valid

### Shared config
✅ settings.json valid
✅ guard-repo.sh executable

### install.sh consistency
✅ "ko" in case statement
⚠️ LANG_DIRS includes "codemaps" but ko has no codemaps/ directory

### Summary
- Checks: 9
- Pass: 8
- Warn: 1
- Fail: 0
```

## Severity levels

- **✅ Pass** — check passed
- **⚠️ Warn** — non-critical issue, may be intentional
- **❌ Fail** — must be fixed before release

## Rules

- Read-only — never modify any files
- Report in English
