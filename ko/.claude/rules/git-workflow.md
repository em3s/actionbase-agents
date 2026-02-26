# Git 워크플로우

## 브랜치 네이밍

```
feature/add-bookmark-schema
fix/null-userid-validation
refactor/simplify-query-builder
```

## 커밋 형식

```
type(scope): description

feat(core): add bookmark schema support
fix(server): validate userId before processing
refactor(engine): simplify query builder logic
test(core): add mutation processing tests
docs(readme): update build instructions
```

## 규칙

- main에 force push 금지
- 머지 전 PR 리뷰 필수
- 머지 전 CI 통과 확인
- PR은 집중적이고 작게 유지
- 명확한 메시지로 자주 커밋
