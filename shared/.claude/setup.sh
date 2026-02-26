#!/usr/bin/env bash
set -euo pipefail

# actionbase-agents local setup
# Configures .claude/settings.local.json with project-specific settings.
#
# Usage:
#   bash .claude/setup.sh
#   bash .claude/setup.sh --upstream kakao/actionbase

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
  python3 - "$CONFIG" "$1" <<'PYEOF'
import json, sys
config, key = sys.argv[1], sys.argv[2]
with open(config) as f:
    d = json.load(f)
v = d.get(key)
if v is not None:
    print(v)
PYEOF
}

# write a key-value to settings.local.json (preserves existing keys)
write_config() {
  python3 - "$CONFIG" "$1" "$2" <<'PYEOF'
import json, sys
config, key, value = sys.argv[1], sys.argv[2], sys.argv[3]
with open(config) as f:
    d = json.load(f)
d[key] = value
with open(config, 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
PYEOF
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

# confirm yes/no (default: Y)
confirm() {
  local label="$1"
  printf "  %s [Y/n]: " "$label" > /dev/tty
  local input
  read -r input < /dev/tty
  [[ -z "$input" || "$input" =~ ^[Yy] ]]
}

# ── parse args ───────────────────────────────────────────────────────

ARG_UPSTREAM=""
while [[ $# -gt 0 ]]; do
  case "$1" in
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

# 2. detect mode from origin
echo ""
[[ -n "$DETECTED" ]] || die "Could not detect repo from git remote origin."
info "origin = $DETECTED"

IS_FORK=false
if echo "$DETECTED" | grep -q '/actionbase$' && \
   ! echo "$DETECTED" | grep -q '^kakao/actionbase$'; then
  IS_FORK=true
fi

if $IS_FORK; then
  info "Mode: fork (origin writes free, others need approval)"
else
  info "Mode: non-fork (all writes need approval)"
fi

# 3. configure git remotes
echo ""
info "Git remotes will be configured as follows:"
if $IS_FORK; then
  info "  origin   → $DETECTED (fetch/push)"
  info "  upstream → $UPSTREAM (fetch only, push disabled)"
else
  info "  origin   → $DETECTED (fetch/push)"
  git remote get-url upstream &>/dev/null && info "  upstream → (will be removed)"
fi
command -v gh &>/dev/null && info "  gh default → $DETECTED"
echo ""

if [[ -t 0 ]] && ! confirm "Apply git remote configuration?"; then
  info "Skipped git remote configuration."
else
  if $IS_FORK; then
    # add/update upstream remote (fetch only, no push)
    if git remote get-url upstream &>/dev/null; then
      git remote set-url upstream "https://github.com/$UPSTREAM.git"
    else
      git remote add upstream "https://github.com/$UPSTREAM.git"
    fi
    git remote set-url --push upstream no_push
    info "upstream → $UPSTREAM (fetch only, push disabled)"
  else
    # remove upstream remote if it exists (not needed in non-fork mode)
    if git remote get-url upstream &>/dev/null; then
      git remote remove upstream
      info "Removed upstream remote"
    fi
  fi

  # set gh default repo
  if command -v gh &>/dev/null; then
    gh repo set-default "$DETECTED" 2>/dev/null || true
    info "gh default → $DETECTED"
  fi
fi

# ── done ─────────────────────────────────────────────────────────────

echo ""
echo "Setup complete. Config saved to $CONFIG"
