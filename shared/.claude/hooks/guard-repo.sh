#!/bin/bash
# Guard: restrict gh write commands, git push, and language violations.
# Reads allowed_repo and upstream_repo from .claude/settings.local.json.
# If not configured, allows all (no guard).

cmd="$CLAUDE_BASH_COMMAND"
CONFIG=".claude/settings.local.json"

# read config values
ALLOWED_REPO=""
UPSTREAM_REPO=""
if [ -f "$CONFIG" ]; then
  eval "$(python3 - "$CONFIG" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    d = json.load(f)
import shlex
print(f"ALLOWED_REPO={shlex.quote(d.get('allowed_repo', ''))}")
print(f"UPSTREAM_REPO={shlex.quote(d.get('upstream_repo', ''))}")
PYEOF
)" 2>/dev/null || true
fi

# if not configured, skip guard
[ -z "$ALLOWED_REPO" ] && exit 0

# determine mode
IS_UPSTREAM=false
[ -n "$UPSTREAM_REPO" ] && [ "$ALLOWED_REPO" = "$UPSTREAM_REPO" ] && IS_UPSTREAM=true

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

# ── language guard (upstream mode only) ─────────────────────────────
# In upstream mode, block non-English content in artifacts.
# Uses Python unicodedata to detect non-Latin scripts (CJK, Hangul, Cyrillic, etc.)
# In Claude Code, the user sees a permission prompt and can approve to override.

if $IS_UPSTREAM; then
  has_non_english() {
    python3 - "$1" <<'PYEOF'
import sys, unicodedata
text = sys.argv[1]
for ch in text:
    cat = unicodedata.category(ch)
    if cat.startswith('L'):  # Letter category
        name = unicodedata.name(ch, '')
        if name and not name.startswith('LATIN'):
            sys.exit(0)  # found non-Latin letter
sys.exit(1)  # all Latin
PYEOF
  }

  needs_check=false
  echo "$cmd" | grep -qE 'gh\s+(issue|pr)\s+(create|edit|comment)' && needs_check=true
  echo "$cmd" | grep -qE 'git\s+commit' && needs_check=true

  if $needs_check && has_non_english "$cmd"; then
    echo "BLOCK: Upstream mode — all artifacts must be in English. Non-English text detected." >&2
    echo "       Rewrite in English and retry, or approve to override." >&2
    exit 2
  fi
fi
