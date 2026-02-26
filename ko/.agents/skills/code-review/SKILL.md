---
name: code-review
description: 최근 변경사항에 대한 코드 리뷰. 보안, 코드 품질, 성능, Actionbase 도메인 규칙을 점검한다. 구현 완료 후 또는 코드 리뷰 요청 시 사용.
---

# Code Review

`git diff`로 최근 변경사항을 리뷰한다. 한국어로 결과를 보고한다.

## 점검 항목

### 보안 (CRITICAL)
- 하드코딩된 인증 정보 (API 키, 비밀번호, 토큰)
- 스토리지 인젝션 위험 (row key에 검증 안 된 입력)
- 입력값 검증 누락
- 인증/인가 문제

### 코드 품질 (HIGH)
- 함수 길이 (>50줄)
- 파일 길이 (>800줄)
- 깊은 중첩 (>4단계)
- 에러 처리
- 테스트 커버리지

### 성능 (MEDIUM)
- 스토리지 스캔 효율성 (무제한 스캔 금지, `setLimit` 필수)
- N+1 쿼리
- 배치 연산 미사용 (`putAll` 대신 개별 `put` 반복)
- 리액티브 코드에서 `.block()` 호출

### Actionbase 도메인 (HIGH)
- **V2/V3 호환성**: V2 API 변경 시 V3에 영향 없는지, 역방향도 확인
- **Row key 설계**: `userId` 우선 배치 (타임스탬프 우선은 핫스팟 유발)
- **CQRS 준수**: Mutation 경로와 Query 경로 분리 유지
- **테스트 패턴**: `@ObjectSource` 사용 여부, `@CsvSource`/`@ValueSource` 지양
- **리액티브 파이프라인**: 블로킹 호출은 반드시 `Schedulers.boundedElastic()`

### 베스트 프랙티스
- 네이밍 컨벤션 (Kotlin: camelCase/PascalCase)
- 주석: WHY 설명, WHAT 아님
- 코드 중복

## 리뷰 프로세스

1. `git diff main...HEAD`로 변경사항 확인
2. 변경된 파일 각각 리뷰
3. 위 점검 항목 기준으로 체크
4. 우선순위별 이슈 보고
5. 수정 방법 제안

## 보고 형식

```
## 코드 리뷰: 변경사항

### 리뷰 파일
- path/to/File.kt

### 발견된 이슈

[CRITICAL] 입력값 검증 누락
파일: server/src/.../Controller.kt:45
문제: 사용자 입력이 검증 없이 스토리지 키에 사용됨
수정: `require(userId.matches(...))` 검증 추가

[HIGH] V2/V3 호환성 미검증
파일: server/src/.../V3Controller.kt:30
문제: V2 API 필드명 변경이 V3 응답에 반영 안 됨
수정: 호환성 테스트 추가 필요

[MEDIUM] 무제한 스캔
파일: engine/src/.../QueryEngine.kt:60
문제: Scan에 limit 미설정
수정: `.setLimit(100)` 추가

### 판정: BLOCK
CRITICAL 이슈 수정 후 머지하세요.
```

## 판정 기준

- **APPROVE**: CRITICAL, HIGH 이슈 없음
- **CAUTION**: MEDIUM 이슈만 있음
- **BLOCK**: CRITICAL 또는 HIGH 이슈 발견
