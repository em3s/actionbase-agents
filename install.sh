#!/usr/bin/env bash
set -euo pipefail

# actionbase-agents on-demand installer
# Installs AI agent config into an actionbase project root.
#
# Usage (from actionbase repo root):
#   bash <(curl -fsSL https://raw.githubusercontent.com/em3s/actionbase-agents/main/install.sh)
#
# Non-interactive:
#   bash <(curl -fsSL ...) --lang ko

REPO="em3s/actionbase-agents"
BRANCH="main"
TARBALL_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
LANG_DIRS="agents commands rules skills"

TMP=""
trap 'rm -rf "$TMP"' EXIT

# ── helpers ───────────────────────────────────────────────────────────

die()  { printf "ERROR: %s\n" "$*"; exit 1; }
info() { printf "  %s\n" "$*"; }

# ── 1. prerequisites ─────────────────────────────────────────────────

command -v curl >/dev/null 2>&1 || die "curl not found."
command -v tar  >/dev/null 2>&1 || die "tar not found."

# ── 2. project root check ────────────────────────────────────────────

[[ -f settings.gradle.kts ]] || die "settings.gradle.kts not found. Run from actionbase project root."
grep -q 'actionbase' settings.gradle.kts || die "Not an actionbase project (settings.gradle.kts missing 'actionbase')."

# ── 3. language selection ─────────────────────────────────────────────

select_language() {
  exec 3</dev/tty 2>/dev/null || die "Cannot open terminal. Use --lang ko or --lang en."

  printf "\n"
  printf "  Select language / 언어를 선택하세요:\n"
  printf "\n"
  printf "    1) 한국어 (Korean)\n"
  printf "    2) English\n"
  printf "\n"
  printf "  > "

  local choice
  read -r choice <&3
  exec 3<&-

  case "$choice" in
    1|ko|korean|한국어)  echo "ko" ;;
    2|en|english|영어)   echo "en" ;;
    *)                   die "Invalid selection: $choice" ;;
  esac
}

LANG_CODE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang) LANG_CODE="$2"; shift 2 ;;
    *)      die "Unknown option: $1" ;;
  esac
done

if [[ -z "$LANG_CODE" ]]; then
  LANG_CODE="$(select_language)"
fi

case "$LANG_CODE" in
  ko|en) ;;
  *)     die "Unsupported language: $LANG_CODE (use ko or en)" ;;
esac

# ── 4. download tarball ──────────────────────────────────────────────

TMP="$(mktemp -d)"
echo ""
echo "Downloading $REPO ($BRANCH)..."
curl -fsSL "$TARBALL_URL" -o "$TMP/archive.tar.gz"
tar xzf "$TMP/archive.tar.gz" -C "$TMP"

EXTRACT_DIR="$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -1)"
[[ -d "$EXTRACT_DIR" ]] || die "Failed to extract tarball."

LANG_DIR="$EXTRACT_DIR/$LANG_CODE"
SHARED_DIR="$EXTRACT_DIR/shared"

[[ -d "$LANG_DIR" ]]   || die "Language pack not found: $LANG_CODE"
[[ -d "$SHARED_DIR" ]] || die "Shared config not found."

# ── 5. install files ─────────────────────────────────────────────────

if [[ -f CLAUDE.md && -d .claude ]]; then
  MODE="update"
else
  MODE="install"
fi

echo ""
echo "${MODE^}ing actionbase-agents (lang=$LANG_CODE)..."

# CLAUDE.md (from language pack)
cp "$LANG_DIR/CLAUDE.md" ./CLAUDE.md
info "CLAUDE.md"

# .claude/ directory
mkdir -p .claude

# language-specific directories — rm then copy
for sub in $LANG_DIRS; do
  if [[ -d "$LANG_DIR/.claude/$sub" ]]; then
    rm -rf ".claude/$sub"
    cp -R "$LANG_DIR/.claude/$sub" ".claude/$sub"
    count="$(find ".claude/$sub" -type f | wc -l | tr -d ' ')"
    info ".claude/$sub/ ($count files)"
  fi
done

# shared: settings.json — overwrite
cp "$SHARED_DIR/.claude/settings.json" .claude/settings.json
info ".claude/settings.json"

# shared: codemaps/ — rm then copy
if [[ -d "$SHARED_DIR/.claude/codemaps" ]]; then
  rm -rf ".claude/codemaps"
  cp -R "$SHARED_DIR/.claude/codemaps" ".claude/codemaps"
  count="$(find ".claude/codemaps" -type f | wc -l | tr -d ' ')"
  info ".claude/codemaps/ ($count files)"
fi

# shared: hooks/ — rm then copy
if [[ -d "$SHARED_DIR/.claude/hooks" ]]; then
  rm -rf ".claude/hooks"
  cp -R "$SHARED_DIR/.claude/hooks" ".claude/hooks"
  info ".claude/hooks/"
fi

# shared: setup.sh — overwrite
if [[ -f "$SHARED_DIR/.claude/setup.sh" ]]; then
  cp "$SHARED_DIR/.claude/setup.sh" .claude/setup.sh
  chmod +x .claude/setup.sh
  info ".claude/setup.sh"
fi

# ── 6. settings.local.json — preserve or create ──────────────────────

if [[ -f .claude/settings.local.json ]]; then
  info ".claude/settings.local.json (kept)"
else
  echo '{}' > .claude/settings.local.json
  info ".claude/settings.local.json (created)"
fi

# ── 7. summary ────────────────────────────────────────────────────────

echo ""
echo "Done! actionbase-agents ${MODE}ed (lang=$LANG_CODE)."

# ── 8. run setup on first install ────────────────────────────────────

if [[ "$MODE" == "install" && -f .claude/setup.sh ]]; then
  echo ""
  echo "Running initial setup..."
  bash .claude/setup.sh
fi
