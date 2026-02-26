# Actionbase Worker Agent

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

## .claude/ Structure

- `agents/` — 위임용 서브에이전트 (planner, architect, code-reviewer, security-reviewer, e2e-runner, refactor-cleaner)
- `commands/` — 슬래시 커맨드 (plan, implement, continue, stage-to-issue, code-review, pr-korean, patch-upstream, bedtime, reset-worktree)
- `skills/` — 컨텍스트 스킬 (actionbase-concepts, v3-transition, strategic-compact, verification-loop, testing-guide)
- `rules/` — 항상 적용되는 가이드라인 (보안, 코딩 스타일, 테스트, git 워크플로우, 성능, 언어, 에이전트, 환경)
- `codemaps/` — 모듈별 코드맵, `shared/.claude/codemaps/`에서 공유 (architecture, core, engine, server, data)

## Key Commands

### 개발 워크플로우
`/plan` → `/implement` → `/continue` → `/stage-to-issue` → `/code-review`

### 활성 커맨드
- `/code-review` — 최근 변경사항 코드 리뷰
- `/pr-korean` — 한국어 PR 생성/업데이트
- `/patch-upstream` — 패치 + 영어 PR 코멘트
- `/bedtime` — 밤사이 작업할 간단한 태스크 탐색

## Repository Policy

이 Claude는 **한국어 화자와 드래프트를 만드는 작업 도구**다.

### 작업 범위
- **변경은 `allowed_repo`에서만** — `.claude/settings.local.json`의 `allowed_repo`에 설정된 레포에서만 커밋, 푸시, 이슈/PR 생성
- `allowed_repo`가 `upstream_repo`와 다른 경우 (fork 모드), upstream은 읽기 전용
- `upstream_repo`로의 기여는 사람이 수동으로 하거나 `/patch-upstream`을 사용

### 언어 (MANDATORY — 위반 금지)

**⚠️ 이 규칙은 모든 출력에 예외 없이 적용된다. 상세 규칙은 `.claude/rules/language.md` 참조.**

`.claude/settings.local.json`의 `allowed_repo`와 `upstream_repo`를 비교하여 모드를 결정한다.

#### Upstream 모드 (`allowed_repo == upstream_repo`)
- **대화만 한국어. 나머지는 전부 영어.**
- 커밋, PR, 이슈, 리뷰, 코드, 초안 — 전부 영어
- 사용자가 한국어로 요청해도, 산출물 자체는 반드시 영어

#### Fork 모드 (`allowed_repo ≠ upstream_repo`)
- **대화: 한국어** — 사용자와의 모든 대화, 설명, 질문
- **fork 산출물: 한국어** — 이슈, PR, 커밋 메시지, 리뷰, 계획
- **항상 영어:** 코드, 코드 주석, upstream 대상 산출물 (`/patch-upstream`)

## Development Notes

- **코딩 전에 계획** — 요구사항을 이해할 것
- **테스트를 먼저 작성** — 새 기능에는 TDD
- **코딩 후 리뷰** — 보안과 품질 확인
- **자주 커밋** — 작고 집중된 커밋
- **컨벤션 준수** — 일관성이 중요
