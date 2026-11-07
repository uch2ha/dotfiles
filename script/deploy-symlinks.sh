#!/usr/bin/env bash
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT


# ── Global configuration ───────────────────
SOURCE_DIR="linux"
TARGET_DIR="$HOME"
FOLDER_MARKER=".folder"

# ── Derived paths ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_ABS="$REPO_ROOT/$SOURCE_DIR"

# ── Inject ─────────────────────────────────
source "$SCRIPT_DIR/_lib.sh"
SECTION="d-links"

# ── CLI flags ──────────────────────────────
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Shared state ───────────────────────────
declare -gi LINKED=0
declare -gi SKIPPED=0

main() {
  if [[ ! -d "$SOURCE_ABS" ]]; then
    warn "Source directory not found: $SOURCE_DIR"
    exit 0
  fi

  info "Linking $SOURCE_ABS -> $TARGET_DIR"
  $DRY_RUN && info "DRY RUN — nothing will be changed"

  _link_tree "$SOURCE_ABS" "$TARGET_DIR"
  success "Linked $LINKED, already ok $SKIPPED"
}

# Walk src: a dir holding $FOLD_MARKER becomes ONE symlink, any other dir is
# recreated and walked, files get one symlink each.
_link_tree() {
  local src="$1" dst="$2" entry
  $DRY_RUN || mkdir -p "$dst"

  shopt -s dotglob nullglob
  for entry in "$src"/*; do
    local name="${entry##*/}"
    [[ "$name" == "$FOLDER_MARKER" ]] && continue
    if [[ -d "$entry" && ! -L "$entry" && ! -e "$entry/$FOLDER_MARKER" ]]; then
      _link_tree "$entry" "$dst/$name"
    else
      _link_one "$entry" "$dst/$name"
    fi
  done
  shopt -u dotglob nullglob
}

_link_one() {
  local src="$1" dst="$2"

  if [[ -e "$dst" && "$(realpath "$dst")" == "$(realpath "$src")" ]]; then
    ((SKIPPED++)) || true
    return
  fi

  if [[ -d "$dst" && ! -L "$dst" ]]; then
    _adopt_dir "$src" "$dst"
  elif [[ -e "$dst" && ! -L "$dst" ]]; then
    fail "Real file in the way: $dst (run script/backup.sh first)"
    exit 1
  fi

  info "${dst/#$HOME/\~} -> ${src#$REPO_ROOT/}"
  if ! $DRY_RUN; then
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$(realpath -m --relative-to="$(dirname "$dst")" "$src")" "$dst"
  fi
  ((LINKED++)) || true
}

# Real dir where a folded link must go: keep its extra content by copying
# whatever the repo dir lacks into it, then drop the real dir.
_adopt_dir() {
  local src="$1" dst="$2"
  [[ -d "$src" ]] || { fail "Real dir in the way of a file: $dst"; exit 1; }

  warn "Folding existing dir, copying its extra content into repo: $dst"
  $DRY_RUN && return
  cp -an "$dst/." "$src/"
  rm -rf "$dst"
}

main "$@"
