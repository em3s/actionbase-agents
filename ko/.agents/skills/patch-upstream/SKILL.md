---
name: patch-upstream
description: 패치 파일 생성 + 한국어 PR을 영어로 번역하여 PR 코멘트로 첨부. origin에 PR이 있어야 실행 가능.
---

# Patch Upstream

현재 브랜치의 diff로 패치 파일을 생성하고, 한국어 PR 본문을 영어로 번역하여 해당 PR에 코멘트로 남긴다.
upstream (kakao/actionbase)에 수동으로 기여할 때 사용.

**전제조건: `pr`으로 origin (em3s/actionbase)에 PR이 이미 존재해야 한다.**

## Workflow

### Step 1: PR 확인 및 본문 읽기

```bash
gh pr view --json number,title,body,url 2>/dev/null
```

- **PR 있음:** PR 번호와 한국어 본문을 확인하고 진행.
- **PR 없음:** "먼저 `pr`으로 PR을 생성하세요." 안내 후 **중단**.

### Step 2: 분석

```bash
git branch --show-current
git diff main...HEAD --stat
git log main...HEAD --oneline
```

사용자에게 보고:
- 현재 브랜치명
- 대상 PR: `#번호`
- 변경된 파일 (stat)
- 커밋 수

**사용자 확인 후 진행.**

### Step 3: 패치 생성

`main` 대비 diff로 패치 파일을 생성한다. `.claude/`와 `CLAUDE.md`는 제외.
파일명은 `em3s-actionbase-pr<번호>.patch` 형식:

```bash
git diff main...HEAD -- . ':!.claude' ':!CLAUDE.md' > /tmp/em3s-actionbase-pr<번호>.patch
```

보고:
- 패치 파일 경로
- 패치 크기 (라인 수)
- 포함된 파일 목록

커밋 기반 패치를 원하는 경우:
```bash
git format-patch main...HEAD -- . ':!.claude' ':!CLAUDE.md' -o /tmp/em3s-actionbase-pr<번호>/
```

### Step 4: 영어 번역 및 PR 코멘트

Step 1에서 읽은 한국어 PR 제목과 본문을 영어로 번역한다.

**번역 원칙:**
- 단순 직역이 아니라, 한국어 뉘앙스를 영어 사용자가 자연스럽게 이해할 수 있도록 의역한다
- 한국어 특유의 표현, 맥락 의존적 서술, 함축적 의미를 영어권 개발자에게 명확하게 전달한다
- 기술 용어는 upstream 프로젝트의 용어를 따른다

먼저 사용자에게 영어 번역본을 보여주고 승인을 받는다.

의역한 부분이 있으면 번역본 아래에 별도로 표시한다:

```
> Translation notes:
> - "원문 표현" → "영어 표현": 의역 이유 설명
```

승인 후 PR에 코멘트로 첨부:

```bash
gh pr comment <번호> --body "$(cat <<'EOF'
## English Translation (for upstream contribution)

**Title:** <영어 제목>

<영어 본문 전체>
EOF
)"
```

**코멘트에 "Generated with Claude Code" 등 AI 귀속 푸터를 절대 넣지 않는다.**

### Step 5: 요약

완료 후 제공:
1. 패치 파일 경로
2. PR 코멘트 URL (영어 번역 포함)
3. 참고 명령어:

```bash
# 대상 레포에서 패치 적용
cd /path/to/kakao/actionbase
git apply /tmp/em3s-actionbase-pr<번호>.patch

# format-patch인 경우
git am /tmp/em3s-actionbase-pr<번호>/*.patch
```
