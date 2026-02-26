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

# 3. configure git remotes
echo ""
if [[ "$REPO" == "$UPSTREAM" ]]; then
  info "Mode: upstream (all artifacts in English)"
else
  info "Mode: fork (conversation + fork artifacts in language pack language)"
fi

echo ""
info "Git remotes will be configured as follows:"
if [[ "$REPO" == "$UPSTREAM" ]]; then
  info "  origin   → $UPSTREAM (fetch/push)"
  git remote get-url upstream &>/dev/null && info "  upstream → (will be removed)"
else
  info "  origin   → $REPO (fetch/push)"
  info "  upstream → $UPSTREAM (fetch only, push disabled)"
fi
command -v gh &>/dev/null && info "  gh default → $REPO"
echo ""

if [[ -t 0 ]] && ! confirm "Apply git remote configuration?"; then
  info "Skipped git remote configuration."
else
  if [[ "$REPO" == "$UPSTREAM" ]]; then
    # origin should point to upstream
    CURRENT_ORIGIN="$(detect_repo || true)"
    if [[ -n "$CURRENT_ORIGIN" && "$CURRENT_ORIGIN" != "$UPSTREAM" ]]; then
      git remote set-url origin "https://github.com/$UPSTREAM.git"
      info "origin → $UPSTREAM"
    fi

    # remove upstream remote if it exists (not needed in upstream mode)
    if git remote get-url upstream &>/dev/null; then
      git remote remove upstream
      info "Removed upstream remote"
    fi

  else
    # origin should point to fork
    CURRENT_ORIGIN="$(detect_repo || true)"
    if [[ -n "$CURRENT_ORIGIN" && "$CURRENT_ORIGIN" != "$REPO" ]]; then
      git remote set-url origin "https://github.com/$REPO.git"
      info "origin → $REPO"
    fi

    # add/update upstream remote (fetch only, no push)
    if git remote get-url upstream &>/dev/null; then
      git remote set-url upstream "https://github.com/$UPSTREAM.git"
    else
      git remote add upstream "https://github.com/$UPSTREAM.git"
    fi
    git remote set-url --push upstream no_push
    info "upstream → $UPSTREAM (fetch only, push disabled)"
  fi

  # set gh default repo
  if command -v gh &>/dev/null; then
    gh repo set-default "$REPO" 2>/dev/null || true
    info "gh default → $REPO"
  fi
fi

# ── done ─────────────────────────────────────────────────────────────

echo ""
echo "Setup complete. Config saved to $CONFIG"
