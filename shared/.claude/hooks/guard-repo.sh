#!/bin/bash
# Guard: restrict gh write commands and git push to the configured repo.
# Reads allowed_repo from .claude/settings.local.json.
# If not configured, allows all (no guard).

cmd="$CLAUDE_BASH_COMMAND"
CONFIG=".claude/settings.local.json"

# read allowed_repo from config
ALLOWED_REPO=""
if [ -f "$CONFIG" ]; then
  ALLOWED_REPO="$(python3 -c "
import json
with open('$CONFIG') as f:
    print(json.load(f).get('allowed_repo', ''))
" 2>/dev/null)"
fi

# if not configured, skip guard
[ -z "$ALLOWED_REPO" ] && exit 0

# gh write commands
if echo "$cmd" | grep -qE 'gh\s+(issue|pr)\s+(create|edit|close|reopen|comment|merge|review)'; then
  if echo "$cmd" | grep -qE '(-R|--repo)'; then
    # explicit -R: must match allowed_repo
    if ! echo "$cmd" | grep -qE "(-R|--repo)\s+$ALLOWED_REPO"; then
      echo "BLOCK: Changes are only allowed in $ALLOWED_REPO." >&2
      exit 1
    fi
  else
    # no -R: check gh default repo
    DEFAULT_REPO="$(gh repo set-default --view 2>/dev/null || true)"
    if [ -n "$DEFAULT_REPO" ] && ! echo "$DEFAULT_REPO" | grep -q "$ALLOWED_REPO"; then
      echo "BLOCK: gh default repo is '$DEFAULT_REPO', not '$ALLOWED_REPO'. Use -R $ALLOWED_REPO or run: gh repo set-default $ALLOWED_REPO" >&2
      exit 1
    fi
  fi
fi

# git push: only origin allowed
if echo "$cmd" | grep -qE 'git\s+push'; then
  for r in $(git remote 2>/dev/null | grep -v '^origin$'); do
    if echo "$cmd" | grep -qw "$r"; then
      echo "BLOCK: Push is only allowed to origin ($ALLOWED_REPO). Cannot use remote '$r'." >&2
      exit 1
    fi
  done
fi
