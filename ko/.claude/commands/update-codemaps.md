---
description: 아키텍처 문서(codemap)를 업데이트합니다.
---

# Update Codemaps 명령어

코드베이스 아키텍처 문서를 생성하고 업데이트합니다.

## Codemap 파일

```
.claude/codemaps/
├── architecture.md   # 전체 아키텍처
├── core.md           # Core 모듈 (model, encoding)
├── engine.md         # Engine 모듈 (storage, messaging)
├── server.md         # Server 모듈 (REST API)
└── data.md           # 데이터 모델, storage 형식
```

참조 문서 (사용자 대상):
- `website/src/content/docs/internals/encoding.mdx` - Row key encoding (확정됨)

## 프로세스

1. **변경 사항 분석**
   - 수정된 소스 파일 확인
   - 아키텍처 변경 식별

2. **문서와 비교**
   - 오래된 섹션 찾기
   - 변경 비율 계산

3. **승인 게이트**
   - 변경이 30%를 초과하면 사용자 승인 요청
   - 업데이트 전 diff 요약 표시

4. **문서 업데이트**
   - 관련 mdx 파일 업데이트
   - 변경 로그에 타임스탬프 추가

## 모듈 구조

```
core/       # Data model, mutation, query, encoding
engine/     # Storage and Messaging bindings
server/     # REST API (Spring WebFlux)
website/    # Documentation (Astro/Starlight)
```

## 사용 예시

```
User: /update-codemaps

Agent:
## Codemap Analysis

### Recent Changes
- core/src/.../MutationProcessor.kt (modified)
- server/src/.../MutationController.kt (modified)

### Codemap Status
| File | Status | Action |
|------|--------|--------|
| codemaps/engine.md | OUTDATED | Update storage interface |
| codemaps/server.md | OK | No changes |
| codemaps/data.md | FIXED | Skip (encoding finalized) |

### Change Summary
- 2 files need updates
- Estimated change: 15%

Proceed with updates? (yes/no)
```

## 규칙

- `internals/encoding.mdx`는 절대 수정하지 않음 (row key 형식이 확정됨)
- 문서를 간결하고 정확하게 유지
- 필요한 경우 다이어그램 사용
- 관련 문서 간 상호 참조
