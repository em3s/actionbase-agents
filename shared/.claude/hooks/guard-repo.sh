#!/bin/bash
# Guard: restrict writes and enforce language policy.
# Detects fork mode automatically from git remote origin.
# Fork = origin matches */actionbase but is NOT kakao/actionbase.

cmd="$CLAUDE_BASH_COMMAND"

# ── detect origin repo ─────────────────────────────────────────────

ORIGIN_REPO=""
ORIGIN_URL="$(git remote get-url origin 2>/dev/null)" || true
if [ -n "$ORIGIN_URL" ]; then
  ORIGIN_REPO="$(echo "$ORIGIN_URL" | sed -E 's#^.*(github\.com[:/])##; s#\.git$##')"
fi

# no origin detected — skip guard
[ -z "$ORIGIN_REPO" ] && exit 0

# ── determine mode ─────────────────────────────────────────────────
# Fork mode: origin is an actionbase fork (not kakao's)

IS_FORK=false
if echo "$ORIGIN_REPO" | grep -q '/actionbase$' && \
   ! echo "$ORIGIN_REPO" | grep -q '^kakao/actionbase$'; then
  IS_FORK=true
fi

# ── gh write commands ──────────────────────────────────────────────

if echo "$cmd" | grep -qE 'gh\s+(issue|pr)\s+(create|edit|close|reopen|comment|merge|review)'; then
  if $IS_FORK; then
    # Fork mode: allow writes to own fork, confirm for others
    if echo "$cmd" | grep -qE '(-R|--repo)'; then
      if ! echo "$cmd" | grep -qE "(-R|--repo)\s+$ORIGIN_REPO"; then
        echo "CONFIRM: Fork mode — this targets a repo other than your fork ($ORIGIN_REPO)." >&2
        echo "         Approve to proceed, or rewrite with -R $ORIGIN_REPO." >&2
        exit 2
      fi
    else
      DEFAULT_REPO="$(gh repo set-default --view 2>/dev/null || true)"
      if [ -n "$DEFAULT_REPO" ] && ! echo "$DEFAULT_REPO" | grep -q "$ORIGIN_REPO"; then
        echo "CONFIRM: Fork mode — gh default repo is '$DEFAULT_REPO', not '$ORIGIN_REPO'." >&2
        echo "         Approve to proceed, or run: gh repo set-default $ORIGIN_REPO" >&2
        exit 2
      fi
    fi
  else
    # Non-fork mode: ALL gh write commands require confirmation
    echo "CONFIRM: Non-fork mode — all write operations require approval." >&2
    exit 2
  fi
fi

# ── git push ───────────────────────────────────────────────────────

if echo "$cmd" | grep -qE 'git\s+push'; then
  if $IS_FORK; then
    # Fork mode: allow push to origin, confirm for other remotes
    for r in $(git remote 2>/dev/null | grep -v '^origin$'); do
      if echo "$cmd" | grep -qw "$r"; then
        echo "CONFIRM: Fork mode — pushing to '$r' (not origin). Approve to proceed." >&2
        exit 2
      fi
    done
  else
    # Non-fork mode: ALL pushes require confirmation
    echo "CONFIRM: Non-fork mode — all push operations require approval." >&2
    exit 2
  fi
fi

# ── language guard (non-fork mode only) ────────────────────────────
# Non-fork mode: all artifacts must be in English.
# Detects non-Latin scripts (CJK, Hangul, Cyrillic, etc.) via unicodedata.

if ! $IS_FORK; then
  has_non_english() {
    python3 - "$1" <<'PYEOF'
import sys, unicodedata
text = sys.argv[1]
for ch in text:
    cat = unicodedata.category(ch)
    if cat.startswith('L'):
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
    echo "CONFIRM: Non-fork mode — all artifacts must be in English. Non-English text detected." >&2
    echo "         Rewrite in English and retry, or approve to override." >&2
    exit 2
  fi
fi
