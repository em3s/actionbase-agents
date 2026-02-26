---
description: Sequentially verifies build, test, security, and diff review after implementation is complete.
---

# Verification Loop

A quality verification checklist to run after implementation, before creating a PR.

## Verification Steps

### 1. Build
```bash
./gradlew build
```
- If it fails, stop immediately and fix build errors first

### 2. Test
```bash
./gradlew test
```
- Check and fix failing tests
- Verify new features have tests

### 3. Security Scan
In modified `*.{kt,java}` files, check for:
- Hardcoded secrets: `API_KEY|SECRET|PASSWORD|TOKEN` (case insensitive)
- Debug code: `println|System\.out\.|\.block()`
- Unvalidated input used in storage keys

### 4. Diff Review
```bash
git diff main...HEAD
```
- Check for unintended changes
- Verify error handling is not missing
- Check V2/V3 compatibility impact

## Result Report

```
## Verification Result

| Phase | Status | Details |
|-------|--------|---------|
| Build | PASS | |
| Test | PASS | 42 tests passed |
| Security | WARN | 1 println found |
| Diff Review | PASS | |

**Result: READY** (or BLOCKED)
```

## When to Use

- After `/implement` is complete, before creating a PR
- As a pre-check before `/code-review`
- After refactoring, to check for regressions
