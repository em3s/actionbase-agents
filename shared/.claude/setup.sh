#!/usr/bin/env bash
set -euo pipefail

# actionbase-agents local setup
# Configures .claude/settings.local.json with project-specific settings.
#
# Usage:
#   bash .claude/setup.sh
#   bash .claude/setup.sh --repo kakao/actionbase
#   bash .claude/setup.sh --repo em3s/actionbase --upstream kakao/actionbase

CONFIG=".claude/settings.local.json"
DEFAULT_UPSTREAM="kakao/actionbase"

die()  { printf "ERROR: %s\n" "$*"; exit 1; }
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

# prompt with default value, return user input or default
prompt() {
  local label="$1" default="$2"
  if [[ -n "$default" ]]; then
    printf "  %s [%s]: " "$label" "$default" > /dev/tty
  else
    printf "  %s: " "$label" > /dev/tty
  fi
  local input
  read -r input < /dev/tty
  echo "${input:-$default}"
}

# ── parse args ───────────────────────────────────────────────────────

ARG_REPO=""
ARG_UPSTREAM=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)     ARG_REPO="$2"; shift 2 ;;
    --upstream) ARG_UPSTREAM="$2"; shift 2 ;;
    *)          die "Unknown option: $1" ;;
  esac
done

# ── setup ────────────────────────────────────────────────────────────

echo ""
echo "actionbase-agents setup"
echo ""

DETECTED="$(detect_repo || true)"

# 1. upstream_repo
CUR_UPSTREAM="$(read_config upstream_repo || true)"
if [[ -n "$ARG_UPSTREAM" ]]; then
  UPSTREAM="$ARG_UPSTREAM"
elif [[ -t 0 ]]; then
  UPSTREAM="$(prompt "Upstream repo" "${CUR_UPSTREAM:-$DEFAULT_UPSTREAM}")"
else
  UPSTREAM="${CUR_UPSTREAM:-$DEFAULT_UPSTREAM}"
fi
[[ -n "$UPSTREAM" ]] || die "No upstream repo specified."
write_config "upstream_repo" "$UPSTREAM"
info "upstream_repo = $UPSTREAM"

# 2. allowed_repo
CUR_ALLOWED="$(read_config allowed_repo || true)"
if [[ -n "$ARG_REPO" ]]; then
  REPO="$ARG_REPO"
elif [[ -t 0 ]]; then
  REPO="$(prompt "Allowed repo (your fork or upstream)" "${CUR_ALLOWED:-$DETECTED}")"
else
  REPO="${CUR_ALLOWED:-$DETECTED}"
fi
[[ -n "$REPO" ]] || die "No repo specified and could not detect from origin."
write_config "allowed_repo" "$REPO"
info "allowed_repo = $REPO"

# 3. show mode
echo ""
if [[ "$REPO" == "$UPSTREAM" ]]; then
  info "Mode: upstream (all artifacts in English)"
else
  info "Mode: fork (conversation + fork artifacts in language pack language)"
fi

# ── done ─────────────────────────────────────────────────────────────

echo ""
echo "Setup complete. Config saved to $CONFIG"
