---
description: Guides optimal compact timing to prevent context loss during long sessions.
---

# Strategic Compact

Auto-compact can occur mid-task, causing important context to be lost.
This skill recommends manual compact at logical transition points.

## When to Compact

### Recommended
- **Exploration → Planning**: After finishing code exploration, before creating a plan
- **Planning → Implementation**: After the plan is finalized, before starting to code
- **Implementation → Review**: After implementation is complete, before `/code-review`
- **Debugging → New Task**: After fixing a bug, before moving to a different task
- **Failed Approach → Retry**: After hitting a dead end, before trying a new direction

### Prohibited
- Mid-implementation (variable names, file paths, state will be lost)
- During multi-file modifications
- While debugging test failures

## What Survives Compact

- CLAUDE.md instructions
- TodoWrite list
- Memory files (`~/.claude/projects/*/memory/`)
- Git state (branch, commit history)
- Files saved to disk

## What Gets Lost During Compact

- Previous conversation content (replaced by summary)
- Contents of files you've read
- Intermediate reasoning
- Tool call results

## How to Practice

At stage transitions during long sessions:
1. Record current progress in TodoWrite
2. Note key decisions or discoveries (in memory files if needed)
3. Run `/compact`
4. Resume work from the TodoWrite list after compact
