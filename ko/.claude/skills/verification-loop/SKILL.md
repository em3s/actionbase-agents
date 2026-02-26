---
description: 구현 완료 후 빌드, 테스트, 보안, diff 리뷰를 순차적으로 검증합니다.
---

# Verification Loop

구현 완료 후, PR 생성 전에 실행하는 품질 검증 체크리스트.

## 검증 단계

### 1. Build
```bash
./gradlew build
```
- 실패 시 즉시 중단, 빌드 오류 수정 우선

### 2. Test
```bash
./gradlew test
```
- 실패한 테스트 확인 및 수정
- 새 기능에 테스트가 있는지 확인

### 3. Security Scan
변경된 `*.{kt,java}` 파일에서:
- 하드코딩된 시크릿: `API_KEY|SECRET|PASSWORD|TOKEN` (대소문자 무시)
- 디버그 코드: `println|System\.out\.|\.block()`
- 검증 안 된 입력이 스토리지 키에 사용되는지

### 4. Diff Review
```bash
git diff main...HEAD
```
- 의도하지 않은 변경 확인
- 에러 처리 누락 확인
- V2/V3 호환성 영향 확인

## 결과 보고

```
## Verification Result

| Phase | Status | Details |
|-------|--------|---------|
| Build | PASS | |
| Test | PASS | 42 tests passed |
| Security | WARN | 1 println found |
| Diff Review | PASS | |

**Result: READY** (또는 BLOCKED)
```

## 사용 시점

- `/implement` 완료 후, PR 생성 전
- `/code-review` 전 사전 점검
- 리팩토링 후 regression 확인
