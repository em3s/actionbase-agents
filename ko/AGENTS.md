# Actionbase Worker Agent

이 파일은 Codex가 이 레포지토리의 코드를 작업할 때 가이드를 제공한다.

## Project Overview

[kakao/actionbase](https://github.com/kakao/actionbase) — 대규모 사용자 인터랙션(좋아요, 조회, 팔로우)을 제공하는 데이터베이스. **누가(who)** **무엇을(what)** **어떤 대상에(target)** 했는가.

**기술 스택**: Kotlin, Spring WebFlux (reactive), HBase (스토리지), Kafka (CDC 이벤트)

## Build & Test

```bash
./gradlew build                    # 전체 빌드
./gradlew test                     # 전체 테스트
./gradlew :core:build              # 특정 모듈
./gradlew build --stacktrace       # 디버깅
```

## Architecture

```
Server (WebFlux) → Engine (바인딩) → Core (모델)
```

| 모듈 | 목적 |
|------|------|
| `core` | 데이터 모델, 인코딩, 유효성 검증 |
| `engine` | Storage/Messaging 바인딩 |
| `server` | Spring WebFlux API 서버 |

Ecosystem: `cli/`, `website/`, `docker/`, `bin/`, `dev/`, `guides/` 등 도구와 문서.

## 사용 가능한 스킬 & 에이전트

### 도메인 지식 스킬
- **actionbase-concepts**: 핵심 개념 — mutation, query, schema, datastore 아키텍처
- **v3-transition**: V2→V3 엔진 전환 패턴과 추상화 설계
- **testing-guide**: 데이터 중심 테스트, @ObjectSource 패턴, E2E/Unit 테스트 구조
- **strategic-compact**: 긴 세션에서 최적의 compact 시점 안내
- **verification-loop**: 빌드, 테스트, 보안, diff 리뷰 체크리스트

### 워크플로우 스킬
- **plan**: 요구사항 분석 → GitHub 이슈 생성
- **implement**: 이슈 → 브랜치 → PR → 구현 → 리뷰 → 반복
- **continue**: 기존 PR을 중단된 지점부터 재개
- **code-review**: 최근 변경사항 보안, 품질, 성능 리뷰
- **pr**: 현재 브랜치의 PR 생성/업데이트
- **patch-upstream**: 패치 생성 + 영어 PR 코멘트
- **bedtime**: 밤사이 작업할 간단한 태스크 탐색
- **stage-to-issue**: 사이드 작업을 GitHub 이슈로 기록
- **reset-worktree**: upstream main pull 후 worktree 리셋

### 에이전트 역할
- **architect**: 시스템 설계, 확장성, 기술 결정
- **code-reviewer**: 코드 품질 및 보안 리뷰
- **planner**: 복잡한 기능의 구현 계획 수립
- **security-reviewer**: 취약점 탐지 및 수정
- **e2e-runner**: 통합 테스트
- **refactor-cleaner**: 불필요한 코드 정리 및 통합

## Repository Policy

이 에이전트는 **한국어 화자와 드래프트를 만드는 작업 도구**다.

### 작업 범위
- **Fork 자동 감지** — `git remote get-url origin`에서 모드를 결정
  - Fork 모드: origin이 `*/actionbase`이고 `kakao/actionbase`가 아닌 경우
  - Non-fork 모드: 그 외 전부
- Fork 모드: origin에 자유롭게 쓰기, 나머지는 승인 필요
- Non-fork 모드: 모든 쓰기에 승인 필요
- upstream 기여는 사람이 수동으로 하거나 `patch-upstream` 스킬을 사용

### 언어 (MANDATORY — 위반 금지)

모든 출력에 예외 없이 적용. `git remote get-url origin`으로 모드를 자동 감지한다.

#### Non-fork 모드 (origin이 `kakao/actionbase`이거나 actionbase가 아닌 경우)
- **대화만 한국어. 나머지는 전부 영어.**
- 커밋, PR, 이슈, 리뷰, 코드, 초안 — 전부 영어
- 사용자가 한국어로 요청해도, 산출물 자체는 반드시 영어

#### Fork 모드 (origin이 `*/actionbase`이고 `kakao/actionbase`가 아닌 경우)
- **대화: 한국어** — 사용자와의 모든 대화, 설명, 질문
- **fork 산출물: 한국어** — 이슈, PR, 커밋 메시지, 리뷰, 계획
- **항상 영어:** 코드, 코드 주석, upstream 대상 산출물 (`patch-upstream`)

### Write Safety (Critical)

쓰기 작업 (`git push`, `gh issue/pr create/edit`) 전 모드를 판별:
1. 실행: `git remote get-url origin`
2. origin이 `*/actionbase`이고 `kakao/actionbase`가 아님 → **Fork 모드**
3. 그 외 → **Non-fork 모드**

**Fork 모드**: origin에 자유롭게 쓰기. 다른 remote에는 사용자 확인 후 쓰기.
**Non-fork 모드**: 모든 쓰기 작업 전에 사용자 확인.

## Development Notes

- **코딩 전에 계획** — 요구사항을 이해할 것
- **테스트를 먼저 작성** — 새 기능에는 TDD
- **코딩 후 리뷰** — 보안과 품질 확인
- **자주 커밋** — 작고 집중된 커밋
- **컨벤션 준수** — 일관성이 중요

---

## 코딩 스타일

### 일반 규칙
- **파일 크기**: 최대 800줄
- **함수 크기**: 최대 50줄
- **중첩 깊이**: 최대 4단계
- **불변성**: 불변 자료구조 우선
- **백엔드 언어**: Kotlin 우선

### Kotlin 패턴

```kotlin
// Data class (기본값 포함)
data class Edge(
    val version: Long,
    val source: Any,
    val target: Any,
    val properties: Map<String, Any?> = emptyMap(),
)

// Sealed class (타입 계층)
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

// blocking 호출에는 boundedElastic 사용
Mono.fromCallable { blockingStorageCall() }
    .subscribeOn(Schedulers.boundedElastic())
```

### 아키텍처 패턴
- **CQRS**: Mutation 경로와 Query 경로 분리
- **Repository 패턴**: 데이터 접근 추상화
- **Reactive Streams**: Spring WebFlux를 통한 non-blocking I/O

### 흐름 가독성
비즈니스 로직은 **한 체인에서 위에서 아래로 읽혀야** 한다. 공통 로직을 인프라 함수로 추출하고 비즈니스 로직을 caller 람다로 남기지 말 것.

### 주석 규칙
- WHY를 설명, WHAT이 아님
- public API는 KDoc
- 주석 처리된 코드 삭제 (git history 활용)

### 네이밍 컨벤션
- **Kotlin/Java**: `camelCase` 변수, `PascalCase` 클래스
- **파일**: `PascalCase.kt` (Kotlin), `PascalCase.java` (Java)

---

## Git 워크플로우

### 브랜치 네이밍
```
feature/add-bookmark-schema
fix/null-userid-validation
refactor/simplify-query-builder
```

### 커밋 형식
```
type(scope): description

feat(core): add bookmark schema support
fix(server): validate userId before processing
```

### 규칙
- main에 force push 금지
- 머지 전 PR 리뷰 필수
- 머지 전 CI 통과 확인
- PR은 집중적이고 작게 유지
- 명확한 메시지로 자주 커밋

---

## 보안 규칙 (CRITICAL)

### 커밋 전 체크리스트
- [ ] 하드코딩된 시크릿 없음 (API 키, 비밀번호, 토큰)
- [ ] 모든 사용자 입력 검증됨
- [ ] API 엔드포인트 입력 새니타이징
- [ ] 에러 메시지에 민감 정보 미포함

### 시크릿 관리
```kotlin
// NEVER: 하드코딩
val apiKey = "sk-proj-xxxxx"

// ALWAYS: 환경변수
val apiKey = System.getenv("API_KEY")
    ?: throw IllegalStateException("API_KEY not configured")
```

### 우선순위: CRITICAL > HIGH > MEDIUM
- **CRITICAL**: 하드코딩된 인증 정보, 스토리지 인젝션, 입력값 검증 누락, 인증/인가 문제
- **HIGH**: 에러 처리에서 민감 정보 노출, 로그에 시크릿 기록, 의존성 취약점
- **MEDIUM**: CORS 설정, Rate limiting, 세션 관리

---

## 성능 가이드라인

### Storage
```kotlin
// GOOD: Bounded scan
val scan = Scan().setPrefix(prefix).setLimit(100)

// BAD: Unbounded scan
val scan = Scan()  // Full table scan!

// GOOD: Batch writes
storage.putAll(listOfPuts)  // Single RPC
```

### 일반 규칙
- N+1 쿼리 방지
- 페이지네이션 사용 (cursor 기반)
- 자주 접근하는 데이터는 캐시
- 최적화 전에 프로파일링
- 리액티브 코드에서 blocking 호출에는 `Schedulers.boundedElastic()` 사용

---

## 환경

### macOS 셸 명령어
alias나 sandbox 충돌을 방지하기 위해 전체 경로 사용 (`/bin/rm`, `/bin/cp`, `/bin/mv`).

### 파일 작업
- 셸에서 파일 삭제 시 `/bin/rm` 사용
- 셸에서 파일 복사 시 `/bin/cp` 사용
