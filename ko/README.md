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

### A. Fork 모드 (개인 fork에서 작업)

origin이 `*/actionbase`이고 `kakao/actionbase`가 아닌 경우 자동 감지.

```
git remote -v
  origin    → em3s/actionbase        (fetch/push)
  upstream  → kakao/actionbase       (fetch only, push = no_push)
```

| 항목 | 동작 |
|------|------|
| 대화 | 한국어 |
| 커밋, PR, 이슈 | 한국어 |
| 코드, 주석 | 영어 |
| upstream 기여 (`/patch-upstream`) | 영어 |
| origin 쓰기 (push, PR 등) | ✅ 허용 |
| 그 외 쓰기 | ⚠️ 승인 필요 |

### B. Non-fork 모드 (upstream 또는 기타 레포)

그 외 모든 경우 (kakao/actionbase, actionbase가 아닌 레포 등).

```
git remote -v
  origin    → kakao/actionbase       (fetch/push)
```

| 항목 | 동작 |
|------|------|
| 대화 | 한국어 |
| 커밋, PR, 이슈 | 영어 |
| 코드, 주석 | 영어 |
| 모든 쓰기 | ⚠️ 승인 필요 |
