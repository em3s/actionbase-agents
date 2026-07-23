# 글쓰기 스타일 (MANDATORY)

PR/이슈 본문, 코멘트, 리뷰 등 모든 산문 산출물에 적용된다. 목표: **개발자가 직접 쓴 글처럼 읽히는 것.** 장황함, 기계적 완결성, 인위적 구조가 보이면 실패다.

## 열기 — 왜부터

- 변경의 동기가 된 문제·사건·관찰로 시작한다 (1–3문장). 무엇을 하는지는 그다음.
- 제목을 재진술하는 여는 문장 금지 ("This PR introduces...")

```
Not all filesystems support `If-Match`. I introduced a dependency on this feature when I added GC boundary files. This PR adds a config to disable it.
```

## 분량 — 변경 크기에 비례

- 사소한 수정은 헤더 없이 한두 문장이 전부: "`main` is failing after #1921"
- 할 말 없는 섹션은 지우거나 "None." 한마디
- 내용이 끝나면 글도 끝난다. 마무리 요약 문단 금지

## 문장

- 1인칭, 능동. 내가 한 일과 판단은 내가 주어 (영어는 축약형 사용: it's, don't, I'll)
- 짧은 평서문. 조각문 허용
- 검증한 사실은 단정한다. 검증 안 한 것만 그렇다고 밝힌다: "I haven't verified this, but ..."
- 장식적 헤징 금지 — 확인한 것에 "아마도"를 붙이지 않는다
- 트레이드오프는 산문으로 — 단점 한 문장 + 재방문 조건: "The downside is X. If that becomes a problem, we can revisit."
- 안 하기로 한 일은 명시하고 미룬다: "I'll leave that for a future PR."

## 포맷

- **인위적 줄바꿈 금지 — 한 문단 = 한 줄.** 줄바꿈은 문단 사이에만
- 문단은 1–4문장
- 불릿은 3–6개의 짧은 명령형 ("Add test", "Update bindings"). diff를 파일별로 재나열하지 않는다. "**볼드 접두:**" 불릿 금지
- 번호 목록은 순서·시나리오에만, 표는 비교를 실제로 압축할 때만
- 증거는 서술하지 말고 원본을 붙인다: 로그는 fenced block, CI 실행은 bare URL 한 줄, 제보는 출처를 밝힌 blockquote
- 식별자·설정 키·파일명은 백틱. 이슈 참조는 `#N`, `Closes #N` / `Fixes #N`은 별도 줄

## 금지

- 마케팅 형용사: robust, comprehensive, seamless, powerful, significantly / 강력한, 포괄적인, 매끄러운, 대폭
- 이모지 불릿 장식
- 빈 보일러플레이트 섹션 유지
- AI 귀속 푸터 (AI 사용 공개는 PR 템플릿의 AI Assistance 섹션에서 담백하게)

## 코멘트 레지스터

- 짧고 따뜻하고 단정적으로: "LGTM! Merged", "Nah, this is too much. Closing for now."
- 실수는 가볍게 즉시 인정
- AI가 작업한 부분은 담백하게: "Sol did this. I reviewed things and it seems quite reasonable."
