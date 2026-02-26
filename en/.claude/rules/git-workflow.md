# Git Workflow

## Branch Naming

```
feature/add-bookmark-schema
fix/null-userid-validation
refactor/simplify-query-builder
```

## Commit Format

```
type(scope): description

feat(core): add bookmark schema support
fix(server): validate userId before processing
refactor(engine): simplify query builder logic
test(core): add mutation processing tests
docs(readme): update build instructions
```

## Rules

- No force push to main
- PR review required before merge
- CI must pass before merge
- Keep PRs focused and small
- Commit often with clear messages
