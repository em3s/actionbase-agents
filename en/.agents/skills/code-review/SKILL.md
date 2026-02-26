---
name: code-review
description: Code review of recent changes. Checks security, code quality, performance, and Actionbase domain rules. Use after implementation or when asked to review code.
---

# Code Review

Reviews recent changes via `git diff`. Reports results in English.

## Review Areas

### Security (CRITICAL)
- Hardcoded credentials (API keys, passwords, tokens)
- Storage injection risks (unvalidated input in row keys)
- Missing input validation
- Authentication/authorization issues

### Code Quality (HIGH)
- Function length (>50 lines)
- File length (>800 lines)
- Deep nesting (>4 levels)
- Error handling
- Test coverage

### Performance (MEDIUM)
- Storage scan efficiency (no unbounded scans, `setLimit` required)
- N+1 queries
- Unused batch operations (repeating individual `put` instead of `putAll`)
- `.block()` calls in reactive code

### Actionbase Domain (HIGH)
- **V2/V3 compatibility**: When changing V2 API, verify no impact on V3; and vice versa
- **Row key design**: `userId` first (timestamp-first causes hotspots)
- **CQRS adherence**: Keep Mutation and Query paths separate
- **Test patterns**: Use `@ObjectSource`, avoid `@CsvSource`/`@ValueSource`
- **Reactive pipeline**: Blocking calls must use `Schedulers.boundedElastic()`

### Best Practices
- Naming conventions (Kotlin: camelCase/PascalCase)
- Comments: explain WHY, not WHAT
- Code duplication

## Review Process

1. Check changes with `git diff main...HEAD`
2. Review each modified file
3. Check against review areas above
4. Report issues by priority
5. Suggest fixes

## Report Format

```
## Code Review: Changes

### Reviewed Files
- path/to/File.kt

### Issues Found

[CRITICAL] Missing input validation
File: server/src/.../Controller.kt:45
Issue: User input used in storage key without validation
Fix: Add `require(userId.matches(...))` validation

[HIGH] V2/V3 compatibility not verified
File: server/src/.../V3Controller.kt:30
Issue: V2 API field name change not reflected in V3 response
Fix: Add compatibility test

[MEDIUM] Unbounded scan
File: engine/src/.../QueryEngine.kt:60
Issue: Scan without limit set
Fix: Add `.setLimit(100)`

### Verdict: BLOCK
Fix CRITICAL issues before merging.
```

## Verdict Criteria

- **APPROVE**: No CRITICAL or HIGH issues
- **CAUTION**: Only MEDIUM issues
- **BLOCK**: CRITICAL or HIGH issues found
