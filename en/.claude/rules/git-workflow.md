# Git Workflow

## Commit Titles

Plain imperative titles that state the behavioral contract. No `type(scope):` prefix.
Sole exception: `docs:` prefix for documentation-only changes.

```
Add scan-and-delete for immutable edge tables
Preserve SYNC response contract under systemMutationMode=ASYNC
Immutable edge tables do not emit CDC
docs: update build instructions
```

- Describe the **behavior/contract**, not the mechanics
- Backticks for identifiers: `` `queue/v1` ``, `` `@TableSource` ``
- Number multi-PR sequences against the tracking issue: `... (Step 2 of #422)`
- Name the causing PR in regression fixes: `... (#309 regression)`

## Branch Naming

`type/short-slug`. Include the tracking issue number when there is one.

```
feat/issue-428-queue-v1
fix/immutable-edge-no-cdc
refactor/feature-flags
docs/retire-translations
```

## PR Rules

- Small, focused PRs — large PRs only for a complete vertical feature with tests
- Delete dead code in its own PR **before** the feature work (Step 0)
- Before a refactor, add tests that pin the existing contract
- Stacked PRs are fine — base on the preceding PR's branch, merge bottom-up
- Never absorb out-of-scope changes — record them as separate issues

## PR/Issue Templates (MANDATORY)

**Before creating a PR or issue, always read and follow the target repo's template:**
- PR: `.github/PULL_REQUEST_TEMPLATE.md`
- Issue: `.github/ISSUE_TEMPLATE/` (pick the matching type — bug_report, feature_request, task, question)

actionbase's PR template structure and how to fill it:

```
## Summary        — what and why (dense; identifiers in backticks). Include Closes #N
## Changes        — bulleted per module/file
## How to Test    — exact runnable commands
## AI Assistance  — checkbox + disclose the tool/model used
```

- When something was deliberately left alone, add a `## Not touched` section stating why

## Merge Protocol

- Squash merge — one commit = one PR, main keeps the `(#N)` reference
- **The agent never merges** — finish as a PR; the user does the final review and merge
- CI must pass before merge
- No force push to main

## Finishing Sequence

spotless → build/test → push → check CI → ask the user about merging
