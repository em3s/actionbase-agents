---
description: upstream main을 pull하고 worktree를 최신 main으로 리셋한 뒤 origin에 push.
---

# Reset Worktree

upstream에서 main을 pull하여 최신 상태로 만들고, 현재 worktree를 main으로 리셋한 뒤 origin에도 push한다.
작업 브랜치를 정리하고 깨끗한 상태에서 다시 시작할 때 사용.

## Workflow

### Step 1: 현재 상태 확인

```bash
git branch --show-current
git status --short
git log --oneline -3
```

사용자에게 보고:
- 현재 브랜치명
- 작업 중인 변경사항 유무
- 최근 커밋 3개

**uncommitted 변경사항이 있으면 경고하고 사용자 확인을 받는다. 사용자가 계속 진행을 선택하면 다음 단계로 넘어간다.**

### Step 2: upstream main pull

```bash
git fetch upstream main
git checkout main
git merge upstream/main --ff-only
```

- fast-forward 실패 시 사용자에게 알리고 **중단**.

### Step 3: origin에 push

```bash
git push origin main
```

### Step 4: worktree 브랜치 리셋 (해당 시)

Step 1에서 main이 아닌 브랜치에 있었다면:

```bash
git checkout <원래-브랜치>
git reset --hard main
```

main에 있었다면 이 단계는 건너뛴다.

### Step 5: 요약

완료 후 보고:
- main 최신 커밋 (해시 + 메시지)
- origin push 완료 여부
- 현재 브랜치 상태
