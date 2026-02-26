---
description: Quickly scan GitHub issues before bed to find simple coding tasks to work on overnight. Falls back to codebase scanning if no suitable issues are found.
---

# Bedtime Issue Finder

A tool that helps you find simple, well-defined coding tasks to work on overnight — a 10-minute investment before bed.
Only recommends tasks that don't require complex decisions or discussions, completable in a single session.

**Repository:** Auto-detected from git remote. Defaults to `kakao/actionbase`.

## 2-Phase Workflow

### Phase 1: GitHub Issues

1. Fetch open issues with `gh issue list --state open --limit 30`
2. Review promising candidates in detail with `gh issue view <number>`
3. Evaluate against selection criteria below
4. If enough good issues found → present and stop
5. If insufficient → fill the rest from Phase 2

### Phase 2: Codebase Scan (Fallback)

When GitHub issues are insufficient, quickly scan for work using **Grep** and **Glob** (no builds — it's bedtime, keep it fast):

1. **TODO/FIXME markers** — `TODO|FIXME|HACK|XXX|WORKAROUND` in `*.{kt,java}`
2. **Missing tests** — compare `**/src/main/**` source files against `**/src/test/**`
3. **Code quality** — `println|System\.out\.` and `.block()` in `*.{kt,java}`
4. **Recent changes without tests** — `git log --oneline -10 --name-only` then check for matching test files

Filter scan results by the same criteria as issues: recommend Simple/Medium only.

Suggest creating GitHub issues for scan findings via `/stage-to-issue`.

## Issue Selection Criteria

**Prioritize:**
- Well-scoped, clearly defined issues
- Labels: `good-first-issue`, `bug`, `enhancement`
- Bug fixes, small features, simple improvements
- No architectural decisions or product direction needed
- Completable in one session
- Enough context to start immediately

**Always exclude:**
- Large refactoring or system redesign
- Requires stakeholder confirmation/approval
- Vague requirements or success criteria
- Touches core infrastructure without a clear test path
- Needs design mockups or UX decisions

## Output Format

For each recommendation:

🌙 **Title** [#number](link) or [scan: category]
📝 **One-liner:** What needs to be done, why it's perfect for tonight — 2-3 sentences
⚡ **Difficulty:** Simple/Medium (never recommend Complex)
❓ **Missing info:** What's needed from the user (or "Ready to start!")
🎯 **Overnight completion probability:** High/Medium/Low + brief reason
💡 **Approach:** 1-2 sentences on how to get started

Source labels:
- `[issue]` — GitHub Issues
- `[scan]` — Codebase scan

## Tone

- Encouraging and motivating — a productive alternative to doomscrolling!
- Concise and scannable
- Emphasize the satisfaction of waking up to completed code
- Relaxed, bedtime-appropriate tone
- Highlight the achievability of each task

## Final Recommendation

After presenting options:
1. Which one I'd pick tonight and why
2. Start prompt: `/implement #123` for issues, direct instructions for scan items
3. A word about the satisfaction of waking up to a completed diff

Key goal: help make pre-bed time productive. Light, focused, achievable. No stress from complexity — just excitement for the morning.
