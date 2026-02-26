---
description: Generate or update architecture codemaps for the actionbase project. Codemaps live in shared/.claude/codemaps/ (English only).
---

# Update Codemaps

Generate or update architecture documentation (codemaps) for the actionbase project.

Codemaps are maintained in English under `shared/.claude/codemaps/` and are shared across all language packs.

## Codemap files

```
shared/.claude/codemaps/
├── architecture.md   # Overall architecture, module dependencies, data flow
├── core.md           # Core module (model, encoding, validation)
├── engine.md         # Engine module (storage, messaging)
├── server.md         # Server module (REST API, WebFlux)
└── data.md           # Data model, storage formats, row key design
```

Reference doc (read-only):
- `website/src/content/docs/internals/encoding.mdx` — Row key encoding (finalized, never modify)

## Process

1. **Locate actionbase source**
   - Expect to be run from this repo (actionbase-agents)
   - Ask the user for the actionbase project path if not obvious
   - Read source files from the actionbase project

2. **Analyze changes**
   - Compare current source against existing codemaps
   - Identify outdated sections

3. **Approval gate**
   - Show change summary before updating
   - If changes exceed 30%, require explicit user confirmation

4. **Update codemaps**
   - Write updated files to `shared/.claude/codemaps/`
   - Keep documentation concise and accurate
   - Use diagrams where helpful
   - Cross-reference between related codemaps

## Module structure (actionbase)

```
core/       # Data model, mutation, query, encoding
engine/     # Storage and Messaging bindings
server/     # REST API (Spring WebFlux)
website/    # Documentation (Astro/Starlight)
```

## Report format

```
## Codemap Update

### Source
actionbase @ /path/to/actionbase (commit abc1234)

### Analysis
| File | Status | Action |
|------|--------|--------|
| architecture.md | OUTDATED | Update module diagram |
| core.md | OK | No changes |
| engine.md | OUTDATED | Update storage interface |
| server.md | OK | No changes |
| data.md | FIXED | Skip (encoding finalized) |

### Change summary
- 2 files need updates
- Estimated change: 15%

Proceed with updates?
```

## Rules

- All codemaps must be written in English
- Never modify `internals/encoding.mdx` (row key format is finalized)
- Keep docs concise — focus on architecture, not implementation details
- Always show diff summary before writing
- Cross-reference related docs between codemaps
