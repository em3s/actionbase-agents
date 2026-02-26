# Actionbase Agent (한국어)

## 설치

actionbase 프로젝트 루트에서:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh) --lang ko
```

## 설정

설치 시 자동으로 `setup.sh`가 실행됩니다. 나중에 재설정하려면:

```bash
bash .claude/setup.sh
```

설정은 `.claude/settings.local.json`에 저장됩니다.

## 사용 시나리오

### A. 개인 fork에서 작업

```
git remote -v
  origin    → em3s/actionbase        (fetch/push)
  upstream  → kakao/actionbase       (fetch only, push = no_push)

allowed_repo = em3s/actionbase
```

| 항목 | 동작 |
|------|------|
| 대화 | 한국어 |
| 커밋, PR, 이슈 | 한국어 |
| 코드, 주석 | 영어 |
| upstream 기여 (`/patch-upstream`) | 영어 |
| `git push` | `origin` (fork)만 허용 |
| `upstream` remote | 읽기 전용 (push 차단) |

### B. upstream에서 직접 작업

```
git remote -v
  origin    → kakao/actionbase       (fetch/push)

allowed_repo = kakao/actionbase
```

| 항목 | 동작 |
|------|------|
| 대화 | 한국어 |
| 커밋, PR, 이슈 | 영어 |
| 코드, 주석 | 영어 |
| `git push` | `origin` (upstream)만 허용 |
