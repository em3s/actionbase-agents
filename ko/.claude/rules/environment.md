# 환경 가이드라인

## macOS 관련 사항

### 셸 명령어

alias나 함수 충돌을 방지하기 위해 시스템 명령어의 전체 경로를 사용할 것:

```bash
# GOOD: 절대 경로 사용
/bin/rm file.txt
/bin/rm -r directory/

# BAD: alias나 sandbox 제한과 충돌 가능
rm file.txt
rm -r directory/
```

### 주요 명령어 전체 경로

| 명령어 | 전체 경로 |
|---------|-----------|
| rm | `/bin/rm` |
| cp | `/bin/cp` |
| mv | `/bin/mv` |
| mkdir | `/bin/mkdir` |
| cat | `/bin/cat` |
| ls | `/bin/ls` |

## 디렉토리 구조

이 설정은 모든 worktree에서 공유되도록 **상위 레벨**에 배치됨:

```
/project-actionbase/
├── .claude/              # 이 설정 (공유)
├── CLAUDE.md             # 공유 문서
├── actionbase/           # main worktree
├── ab-agent-1/           # agent-1 worktree
└── ab-agent-2/           # agent-2 worktree
```

Claude Code는 상위 디렉토리에서 `.claude/`를 자동으로 탐색함.

## 작업 디렉토리

- 각 worktree는 독립적인 작업 디렉토리
- Claude Code 세션은 worktree 디렉토리 내에서 시작해야 함
- 공유 `.claude/` 설정이 모든 worktree에 적용됨

## 파일 작업

- 셸 명령어보다 Claude 내장 도구(Read, Write, Edit)를 우선 사용할 것
- 셸에서 파일 삭제가 필요한 경우 `/bin/rm` 사용
- 셸에서 파일 복사 시 `/bin/cp` 사용
