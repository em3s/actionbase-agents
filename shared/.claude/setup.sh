#!/usr/bin/env bash
set -euo pipefail

# actionbase-agents local setup
# Configures .claude/settings.local.json with project-specific settings.
#
# Usage:
#   bash .claude/setup.sh
#   bash .claude/setup.sh --repo kakao/actionbase

CONFIG=".claude/settings.local.json"

die()  { printf "ERROR: %s\n" "$*" >&2; exit 1; }
info() { printf "  %s\n" "$*"; }

# ── prerequisites ────────────────────────────────────────────────────

[[ -f "$CONFIG" ]] || die "$CONFIG not found. Run install.sh first."
command -v python3 >/dev/null 2>&1 || die "python3 required for JSON editing."

# ── helpers ──────────────────────────────────────────────────────────

# detect owner/repo from git remote origin
detect_repo() {
  local url
  url="$(git remote get-url origin 2>/dev/null)" || return 1
  # handle ssh (git@github.com:owner/repo.git) and https
  echo "$url" | sed -E 's#^.*(github\.com[:/])##; s#\.git$##'
}

# read a key from settings.local.json
read_config() {
  python3 -c "
import json, sys
with open('$CONFIG') as f:
    d = json.load(f)
v = d.get('$1')
if v is not None:
    print(v)
" 2>/dev/null
}

# write a key-value to settings.local.json (preserves existing keys)
write_config() {
  python3 -c "
import json
with open('$CONFIG') as f:
    d = json.load(f)
d['$1'] = '$2'
with open('$CONFIG', 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
}

# ── parse args ───────────────────────────────────────────────────────

ARG_REPO=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) ARG_REPO="$2"; shift 2 ;;
    *)      die "Unknown option: $1" ;;
  esac
done

# ── setup: allowed_repo ──────────────────────────────────────────────

echo ""
echo "actionbase-agents setup"
echo ""

DETECTED="$(detect_repo || true)"
CURRENT="$(read_config allowed_repo || true)"

if [[ -n "$ARG_REPO" ]]; then
  REPO="$ARG_REPO"
elif [[ -t 0 ]]; then
  if [[ -n "$CURRENT" ]]; then
    printf "  Allowed repo [%s]: " "$CURRENT"
  elif [[ -n "$DETECTED" ]]; then
    printf "  Allowed repo [%s]: " "$DETECTED"
  else
    printf "  Allowed repo (owner/repo): "
  fi

  read -r REPO
  if [[ -z "$REPO" ]]; then
    REPO="${CURRENT:-$DETECTED}"
  fi
else
  REPO="${CURRENT:-$DETECTED}"
fi

[[ -n "$REPO" ]] || die "No repo specified and could not detect from origin."

write_config "allowed_repo" "$REPO"
info "allowed_repo = $REPO"

# ── done ─────────────────────────────────────────────────────────────

echo ""
echo "Setup complete. Config saved to $CONFIG"
