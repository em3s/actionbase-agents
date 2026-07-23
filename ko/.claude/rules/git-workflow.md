# Git 워크플로우

## 커밋 제목

행동 계약을 서술하는 평서형 제목. `type(scope):` 접두사는 쓰지 않는다.
유일한 예외: 문서 전용 변경은 `docs:` 접두사.

```
Add scan-and-delete for immutable edge tables
Preserve SYNC response contract under systemMutationMode=ASYNC
Immutable edge tables do not emit CDC
docs: update build instructions
```

- 구현 방식이 아니라 **동작/계약**을 서술
- 식별자는 백틱으로: `` `queue/v1` ``, `` `@TableSource` ``
- 연속 PR은 트래킹 이슈에 단계를 표기: `... (Step 2 of #422)`
- 회귀 수정은 원인 PR을 명시: `... (#309 regression)`

## 브랜치 네이밍

`type/short-slug`. 트래킹 이슈가 있으면 번호를 포함.

```
feat/issue-428-queue-v1
fix/immutable-edge-no-cdc
refactor/feature-flags
docs/retire-translations
```

## PR 규칙

- 작고 집중된 PR — 큰 PR은 테스트를 포함한 완결된 수직 기능에만 허용
- 죽은 코드 삭제는 기능 작업 **전에** 별도 PR로 (Step 0)
- 리팩토링 전에 기존 계약을 고정하는 테스트를 먼저 추가
- 스택 PR 허용 — base를 앞 PR 브랜치로 지정하고 아래부터 머지
- 스코프 밖 변경은 절대 끼워넣지 않는다 — 별도 이슈로 기록

## PR/이슈 템플릿 (MANDATORY)

**PR이나 이슈를 생성하기 전에 반드시 대상 레포의 템플릿을 먼저 읽고 따른다:**
- PR: `.github/PULL_REQUEST_TEMPLATE.md`
- 이슈: `.github/ISSUE_TEMPLATE/` (유형에 맞는 템플릿 선택 — bug_report, feature_request, task, question)

actionbase의 PR 템플릿 구조와 작성 요령:

```
## Summary        — 무엇을, 왜 (간결하게, 식별자는 백틱). Closes #N 포함
## Changes        — 모듈/파일별 불릿
## How to Test    — 실행 가능한 정확한 명령어
## AI Assistance  — 체크박스 + 사용한 도구/모델 공개
```

- 의도적으로 손대지 않은 것이 있으면 `## Not touched` 섹션을 추가해 이유와 함께 명시

## 머지 프로토콜

- squash merge — 커밋 1개 = PR 1개, main에는 `(#N)` 참조가 남는다
- **에이전트는 절대 머지하지 않는다** — PR로 마무리하고 사용자가 최종 리뷰·머지
- 머지 전 CI 통과 확인
- main에 force push 금지

## 마무리 시퀀스

spotless → 빌드/테스트 → push → CI 확인 → 머지 여부는 사용자에게 확인
