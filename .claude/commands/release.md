---
description: Pre-release checklist. Validates all language packs, checks consistency, and prepares for tagging.
---

# Release

Run pre-release checklist and prepare for a new version tag.

## Usage

`/release [<version>]`

- `<version>` — semver tag (e.g., `v1.1.0`). If omitted, suggest next version based on git tags.

Examples:
- `/release v1.2.0`
- `/release`

## Pre-release checklist

### 1. Run /validate
- Validate all detected language packs
- Stop if any ❌ Fail is found

### 2. Run /sync-check
- Check consistency across language packs
- Stop if critical mismatches are found (missing required files)

### 3. install.sh checks
- `LANG_DIRS` variable matches actual directory structure
- All available languages are in the case statement
- Curl URL uses correct branch/repo

### 4. CLAUDE.md / README consistency
- "Available Languages" table matches actual language directories
- "Structure" section reflects current directory layout
- File counts in structure comments are accurate

### 5. Git status
- Working tree is clean (no uncommitted changes)
- Current branch is `main`

### 6. Version tag
- Proposed tag doesn't already exist
- Show changelog since last tag (`git log <last-tag>..HEAD --oneline`)

## Process

1. Run checks 1-5 sequentially
2. If all pass — show summary and proposed changelog
3. Pause for user confirmation
4. If confirmed — create annotated git tag
5. Remind user to `git push --tags`

## Report format

```
## Release Checklist: v1.2.0

### Validation
✅ ko: 9/9 pass
✅ en: 9/9 pass

### Sync check
✅ ko ↔ en: all match

### install.sh
✅ LANG_DIRS consistent
✅ All languages in case statement

### CLAUDE.md / README
✅ Language table up to date
⚠️ Structure section: file count outdated (says 10 commands, actual 9)

### Git status
✅ Clean working tree
✅ On main branch

### Changelog since v1.1.0
- abc1234 feat: add /sync-check admin command
- def5678 fix: install.sh language validation
- ghi9012 docs: update Korean agent rules

### Ready to tag?
Waiting for confirmation...
```

## Rules

- Never create a tag without user confirmation
- Never push to remote — only create local tag, remind user to push
- If any ❌ Fail exists, do not proceed to tagging
- ⚠️ Warn items are reported but do not block release
- Report in English
