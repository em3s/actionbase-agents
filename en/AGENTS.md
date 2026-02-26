# Actionbase Worker Agent

This file provides guidance to Codex when working with code in this repository.

## Project Overview

[kakao/actionbase](https://github.com/kakao/actionbase) — A database serving large-scale user interactions (likes, views, follows). **Who** did **what** to **which target**.

**Tech Stack**: Kotlin, Spring WebFlux (reactive), HBase (storage), Kafka (CDC events)

## Build & Test

```bash
./gradlew build                    # Full build
./gradlew test                     # All tests
./gradlew :core:build              # Specific module
./gradlew build --stacktrace       # Debugging
```

## Architecture

```
Server (WebFlux) → Engine (bindings) → Core (model)
```

| Module | Purpose |
|--------|---------|
| `core` | Data models, encoding, validation |
| `engine` | Storage/Messaging bindings |
| `server` | Spring WebFlux API server |

Ecosystem: `cli/`, `website/`, `docker/`, `bin/`, `dev/`, `guides/` — tools and documentation.

## Available Skills & Agents

### Domain Knowledge Skills
- **actionbase-concepts**: Core concepts — mutation, query, schema, datastore architecture
- **v3-transition**: V2→V3 engine transition patterns and abstraction design
- **testing-guide**: Data-driven testing, @ObjectSource patterns, E2E/Unit test structure
- **strategic-compact**: Optimal compact timing for long sessions
- **verification-loop**: Build, test, security, diff review checklist

### Workflow Skills
- **plan**: Analyze requirements → create GitHub issue
- **implement**: Issue → branch → PR → implement → review → iterate
- **continue**: Resume existing PR from where it left off
- **code-review**: Review recent changes for security, quality, performance
- **pr**: Create/update a PR for the current branch
- **patch-upstream**: Generate patch + English PR comment for upstream contribution
- **bedtime**: Find simple tasks to work on overnight
- **stage-to-issue**: Record side tasks as GitHub issues
- **reset-worktree**: Pull upstream main and reset worktree

### Agent Roles
- **architect**: System design, scalability, technical decisions
- **code-reviewer**: Code quality and security review
- **planner**: Implementation planning for complex features
- **security-reviewer**: Vulnerability detection and remediation
- **e2e-runner**: End-to-end testing
- **refactor-cleaner**: Dead code cleanup and consolidation

## Repository Policy

You are a **working tool for English-speaking developers drafting and building**.

### Scope of Work
- **Auto-detected fork mode** — determined from `git remote get-url origin`
  - Fork mode: origin matches `*/actionbase` but not `kakao/actionbase`
  - Non-fork mode: everything else
- Fork mode: write freely to origin, approval required for everything else
- Non-fork mode: approval required for all writes
- Upstream contributions via manual process or the `patch-upstream` skill

### Language (MANDATORY — no exceptions)

All output is in English. Mode is auto-detected from `git remote get-url origin`.

#### Non-fork mode (origin is `kakao/actionbase` or not an actionbase repo)
- **Everything in English.**
- Conversation, commits, PRs, issues, reviews, code, drafts — all English

#### Fork mode (origin matches `*/actionbase` but not `kakao/actionbase`)
- **Conversation: English**
- **Fork artifacts: English** — issues, PRs, commit messages, reviews, plans
- **Always English:** code, code comments, upstream-targeted artifacts

### Write Safety (Critical)

Before any write operation (`git push`, `gh issue/pr create/edit`), determine mode:
1. Run: `git remote get-url origin`
2. If origin matches `*/actionbase` but NOT `kakao/actionbase` → **Fork mode**
3. Otherwise → **Non-fork mode**

**Fork mode**: Write freely to origin. Confirm with user before writing to other remotes.
**Non-fork mode**: Confirm with user before ALL write operations.

## Development Notes

- **Plan before coding** — understand requirements first
- **Write tests first** — TDD for new features
- **Review after coding** — verify security and quality
- **Commit often** — small, focused commits
- **Follow conventions** — consistency matters

---

## Coding Style

### General Rules
- **File size**: Max 800 lines
- **Function size**: Max 50 lines
- **Nesting depth**: Max 4 levels
- **Immutability**: Prefer immutable data structures
- **Backend language**: Kotlin preferred

### Kotlin Patterns

```kotlin
// Data class with defaults
data class Edge(
    val version: Long,
    val source: Any,
    val target: Any,
    val properties: Map<String, Any?> = emptyMap(),
)

// Sealed class for type hierarchy
sealed class EdgeRecord {
    sealed class Key {
        data class CommonPrefix(val source: Any, val tableCode: Int, val typeCode: Byte)
    }
}

// Spring WebFlux
@GetMapping("/users/{id}")
fun getUser(@PathVariable id: String): Mono<User> {
    return userService.findById(id)
}

// Blocking calls must use boundedElastic
Mono.fromCallable { blockingStorageCall() }
    .subscribeOn(Schedulers.boundedElastic())
```

### Architecture Patterns
- **CQRS**: Separate mutation and query paths
- **Repository Pattern**: Data access abstraction
- **Reactive Streams**: Non-blocking I/O via Spring WebFlux

### Flow Readability
Business logic should **read top-to-bottom in a single chain**. Don't extract common logic into infrastructure functions and leave business logic in caller lambdas.

### Comment Rules
- Explain WHY, not WHAT
- KDoc for public APIs
- Delete commented-out code (use git history)

### Naming Conventions
- **Kotlin/Java**: `camelCase` for variables, `PascalCase` for classes
- **Files**: `PascalCase.kt` (Kotlin), `PascalCase.java` (Java)

---

## Git Workflow

### Branch Naming
```
feature/add-bookmark-schema
fix/null-userid-validation
refactor/simplify-query-builder
```

### Commit Format
```
type(scope): description

feat(core): add bookmark schema support
fix(server): validate userId before processing
```

### Rules
- No force push to main
- PR review required before merge
- CI must pass before merge
- Keep PRs focused and small
- Commit often with clear messages

---

## Security Rules (CRITICAL)

### Pre-commit Checklist
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user input validated
- [ ] API endpoint inputs sanitized
- [ ] Error messages contain no sensitive information

### Secret Management
```kotlin
// NEVER: Hardcoded
val apiKey = "sk-proj-xxxxx"

// ALWAYS: Environment variable
val apiKey = System.getenv("API_KEY")
    ?: throw IllegalStateException("API_KEY not configured")
```

### Priority: CRITICAL > HIGH > MEDIUM
- **CRITICAL**: Hardcoded credentials, storage injection, missing input validation, auth issues
- **HIGH**: Sensitive info in error handling, secrets in logs, dependency vulnerabilities
- **MEDIUM**: CORS configuration, rate limiting, session management

---

## Performance Guidelines

### Storage
```kotlin
// GOOD: Bounded scan
val scan = Scan().setPrefix(prefix).setLimit(100)

// BAD: Unbounded scan
val scan = Scan()  // Full table scan!

// GOOD: Batch writes
storage.putAll(listOfPuts)  // Single RPC
```

### General
- Avoid N+1 queries
- Use pagination (cursor-based)
- Cache frequently accessed data
- Profile before optimizing
- Use `Schedulers.boundedElastic()` for blocking calls in reactive code

---

## Environment

### macOS Shell Commands
Use full paths (`/bin/rm`, `/bin/cp`, `/bin/mv`) to avoid alias or sandbox conflicts.

### File Operations
- Use `/bin/rm` when file deletion via shell is needed
- Use `/bin/cp` when file copying via shell is needed
