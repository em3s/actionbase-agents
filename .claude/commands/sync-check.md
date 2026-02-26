---
description: Check structural consistency across language packs. Detects missing files, extra files, and structural drift.
---

# Sync Check

Check structural consistency across language packs.

## Scope

Language directories at project root (`ko/`, `en/`, etc.) containing `.claude/` config files.

## Checks

### 1. File structure comparison
- Compare `.claude/` subdirectory listings across all language packs (`agents/`, `commands/`, `rules/`, `skills/`, `codemaps/`)
- Verify 1:1 filename correspondence — detect files that exist in only one language
- Exclude `shared/` (common to all languages)

### 2. CLAUDE.md structure comparison
- Compare top-level section headings (`##`) across each language's `CLAUDE.md`
- Detect sections that exist in only one language

### 3. Commands signature comparison
- Verify each command file has `description` frontmatter
- Verify command names (filenames) have 1:1 correspondence

### 4. Skills structure comparison
- Verify `skills/` subdirectory names have 1:1 correspondence
- Verify each skill contains `SKILL.md`

## Process

1. Detect language directories at project root (directories containing `CLAUDE.md`)
2. If only 1 language — report "No comparison target, skipping" and stop
3. If 2+ languages — run all checks across every pair
4. Report results

## Report format

```
## Sync Check Report

### Language packs detected
- ko ✓
- en ✓

### File structure: ko ↔ en

#### agents/
✅ Match (6 files)

#### commands/
⚠️ Mismatch
  - ko only: pr-korean.md
  - en only: pr-english.md

#### rules/
✅ Match (6 files)

#### skills/
✅ Match (5 skills)

### CLAUDE.md sections
⚠️ Mismatch
  - ko only: ## 커밋 규칙
  - en only: (none)

### Summary
- Checked: 5 categories
- Match: 3
- Mismatch: 2
- Action needed: sync commands/pr-korean.md, CLAUDE.md sections
```

## Rules

- Read-only — never modify any files
- Language-specific files (e.g., `pr-korean.md`) are reported as mismatch but flagged as "review needed" rather than "action needed" since they may be intentional
- Does not check translation quality — structure only
- Report in English (repo communication policy)
