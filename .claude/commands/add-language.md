---
description: Scaffold a new language pack by cloning structure from an existing one.
---

# Add Language

Scaffold a new language pack directory from an existing one.

## Usage

`/add-language <lang-code> [--from <source-lang>]`

- `<lang-code>` — ISO 639-1 code (e.g., `en`, `ja`, `zh`)
- `--from` — source language to clone structure from (default: `ko`)

Examples:
- `/add-language en`
- `/add-language ja --from ko`

## Process

1. **Validate** — check `<lang-code>` doesn't already exist as a directory
2. **Clone structure** — copy directory tree from source language pack
3. **Create placeholder files** — for each file in source:
   - Copy the file as-is (to be translated later)
   - Prepend a comment `<!-- TODO: translate from <source-lang> -->` to each `.md` file
4. **Create CLAUDE.md** — copy source `CLAUDE.md` with translation TODO marker
5. **Update install.sh** — add the new language to the `case` validation statement
6. **Update CLAUDE.md** — add the new language to the "Available Languages" table with status "In Progress"
7. **Update README.md** — add to language table if README exists
8. **Report** — list all created files

## Report format

```
## Add Language: en

### Created
- en/CLAUDE.md
- en/.claude/agents/ (6 files)
- en/.claude/commands/ (10 files)
- en/.claude/rules/ (6 files)
- en/.claude/skills/ (5 skills)

### Updated
- install.sh (added "en" to language validation)
- CLAUDE.md (added "en" to Available Languages table)

### Next steps
- Translate files in en/ from ko
- Run /sync-check to verify structure
```

## Language rules (must be in every CLAUDE.md)

Every language pack's `CLAUDE.md` must include language rules under `### 언어` / `### Language`.
The mode is determined automatically from `git remote get-url origin`.

### Fork mode (origin matches `*/actionbase` but not `kakao/actionbase`)
| Context | Language |
|---------|----------|
| Conversation with user | Language pack language |
| Fork artifacts (issues, PRs, commits) | Language pack language |
| Code and code comments | Always English |
| Upstream artifacts (`/patch-upstream`) | Always English |

### Non-fork mode (everything else)
| Context | Language |
|---------|----------|
| Conversation with user | Language pack language |
| All artifacts (code, commits, PRs, issues) | Always English |

When scaffolding, adapt these rules to the target language in the new `CLAUDE.md`.

## Rules

- Never overwrite an existing language directory
- Always clone from an existing, complete language pack
- Pause for user confirmation before creating files
- File content is copied as-is — translation is a separate step
- Every new CLAUDE.md must include the language rules table above
