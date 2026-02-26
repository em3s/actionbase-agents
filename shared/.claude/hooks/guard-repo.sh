#!/bin/bash
# Allow-list: only em3s/actionbase is writable
# gh write commands with -R must target em3s/actionbase
# git push is restricted to origin only

cmd="$CLAUDE_BASH_COMMAND"

# gh write commands: -R must be em3s/actionbase (or omitted = current repo)
if echo "$cmd" | grep -qE 'gh\s+(issue|pr)\s+(create|edit|close|reopen|comment|merge|review)'; then
  if echo "$cmd" | grep -qE '(-R|--repo)' && ! echo "$cmd" | grep -qE '(-R|--repo)\s+em3s/actionbase'; then
    echo "BLOCK: Changes are only allowed in em3s/actionbase." >&2
    exit 1
  fi
fi

# git push: only origin allowed
if echo "$cmd" | grep -qE 'git\s+push'; then
  for r in $(git remote 2>/dev/null | grep -v '^origin$'); do
    if echo "$cmd" | grep -qw "$r"; then
      echo "BLOCK: Push is only allowed to origin (em3s/actionbase). Cannot use remote '$r'." >&2
      exit 1
    fi
  done
fi
