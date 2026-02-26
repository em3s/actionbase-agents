# Environment Guidelines

## macOS Considerations

### Shell Commands

Use full paths for system commands to avoid alias or function conflicts:

```bash
# GOOD: Absolute path
/bin/rm file.txt
/bin/rm -r directory/

# BAD: May conflict with aliases or sandbox restrictions
rm file.txt
rm -r directory/
```

### Common Command Full Paths

| Command | Full Path |
|---------|-----------|
| rm | `/bin/rm` |
| cp | `/bin/cp` |
| mv | `/bin/mv` |
| mkdir | `/bin/mkdir` |
| cat | `/bin/cat` |
| ls | `/bin/ls` |

## Directory Structure

This config is placed at the **top level** to be shared across all worktrees:

```
/project-actionbase/
├── .claude/              # This config (shared)
├── CLAUDE.md             # Shared documentation
├── actionbase/           # main worktree
├── ab-agent-1/           # agent-1 worktree
└── ab-agent-2/           # agent-2 worktree
```

Claude Code automatically searches parent directories for `.claude/`.

## Working Directory

- Each worktree is an independent working directory
- Claude Code sessions should start within a worktree directory
- Shared `.claude/` config applies to all worktrees

## File Operations

- Prefer Claude built-in tools (Read, Write, Edit) over shell commands
- Use `/bin/rm` when file deletion via shell is needed
- Use `/bin/cp` when file copying via shell is needed
