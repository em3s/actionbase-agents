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

# ── 3. parse args ────────────────────────────────────────────────────

LANG_CODE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang) LANG_CODE="$2"; shift 2 ;;
    *)      die "Unknown option: $1" ;;
  esac
done

# ── 4. download tarball ──────────────────────────────────────────────

TMP="$(mktemp -d)"
echo ""
echo "Downloading $REPO ($BRANCH)..."
curl -fsSL "$TARBALL_URL" -o "$TMP/archive.tar.gz"
tar xzf "$TMP/archive.tar.gz" -C "$TMP"

EXTRACT_DIR="$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -1)"
[[ -d "$EXTRACT_DIR" ]] || die "Failed to extract tarball."

SHARED_DIR="$EXTRACT_DIR/shared"
[[ -d "$SHARED_DIR" ]] || die "Shared config not found."

# ── 5. language selection (from available packs in tarball) ──────────

# detect language packs: directories containing CLAUDE.md, excluding shared/
AVAILABLE_LANGS=()
for d in "$EXTRACT_DIR"/*/; do
  name="$(basename "$d")"
  [[ "$name" == "shared" ]] && continue
  [[ -f "$d/CLAUDE.md" ]] && AVAILABLE_LANGS+=("$name")
done
[[ ${#AVAILABLE_LANGS[@]} -gt 0 ]] || die "No language packs found in archive."

if [[ -n "$LANG_CODE" ]]; then
  # validate --lang argument
  found=false
  for l in "${AVAILABLE_LANGS[@]}"; do
    [[ "$l" == "$LANG_CODE" ]] && found=true && break
  done
  $found || die "Unsupported language: $LANG_CODE (available: ${AVAILABLE_LANGS[*]})"
elif [[ ${#AVAILABLE_LANGS[@]} -eq 1 ]]; then
  # single language: auto-select with confirmation
  LANG_CODE="${AVAILABLE_LANGS[0]}"
  echo ""
  echo "  Language: $LANG_CODE"
else
  # multiple languages: interactive menu
  exec 3<>/dev/tty 2>/dev/null || die "Cannot open terminal. Use --lang <code>."
  printf "\n"                                    >&3
  printf "  Select language / 언어를 선택하세요:\n" >&3
  printf "\n"                                    >&3
  local_i=1
  for l in "${AVAILABLE_LANGS[@]}"; do
    printf "    %d) %s\n" "$local_i" "$l"        >&3
    local_i=$((local_i + 1))
  done
  printf "\n"                                    >&3
  printf "  > "                                  >&3
  local choice
  read -r choice <&3
  exec 3<&-

  # match by number or code
  LANG_CODE=""
  if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#AVAILABLE_LANGS[@]} ]]; then
    LANG_CODE="${AVAILABLE_LANGS[$((choice - 1))]}"
  else
    for l in "${AVAILABLE_LANGS[@]}"; do
      [[ "$l" == "$choice" ]] && LANG_CODE="$l" && break
    done
  fi
  [[ -n "$LANG_CODE" ]] || die "Invalid selection: $choice"
fi

LANG_DIR="$EXTRACT_DIR/$LANG_CODE"
[[ -d "$LANG_DIR" ]] || die "Language pack not found: $LANG_CODE"

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

# ── 8. run setup ─────────────────────────────────────────────────────

if [[ -f .claude/setup.sh ]]; then
  echo ""
  bash .claude/setup.sh
  echo ""
  echo "To reconfigure later, run: bash .claude/setup.sh"
fi
