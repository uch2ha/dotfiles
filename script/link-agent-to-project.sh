#!/usr/bin/env bash
# Manual use only: link every child of an agent group dir into a project dir.
#   link-agent-to-project.sh [--dry-run] --from <kind> --folders <group>... --to <project-target-dir>
#   e.g. --from skills --folders java-quarkus react-vite --to ~/app/.claude/skills
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT


# ── Derived paths ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Inject ─────────────────────────────────
source "$REPO_ROOT/script/_lib.sh"
SECTION="link-agent"

# ── CLI flags ──────────────────────────────
DRY_RUN=false
FROM=""
TO=""
FOLDERS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --from) FROM="${2:-}"; shift 2 || { echo "--from needs a value"; exit 1; } ;;
    --to) TO="${2:-}"; shift 2 || { echo "--to needs a value"; exit 1; } ;;
    --folders)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do FOLDERS+=("$1"); shift; done ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Shared state ───────────────────────────
declare -g SRC DST KIND_DIR
declare -gi LINKED=0
declare -gi SKIPPED=0
declare -gi PRUNED=0

main() {
  _require_terminal
  _parse_args
  $DRY_RUN && info "DRY RUN — nothing will be changed"

  local group
  for group in "${FOLDERS[@]}"; do
    SRC="$KIND_DIR/$group"
    info "Linking $group -> ${DST/#$HOME/\~}"
    _link_children
    _prune_dead_links
  done
  success "Linked $LINKED, already ok $SKIPPED, pruned $PRUNED"
}

# shortcut: a tty check stops pipes/cron/setup.sh, not a script run from a terminal.
_require_terminal() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    fail "Manual use only: run this from an interactive terminal."
    exit 1
  fi
}

_parse_args() {
  if [[ -z "$FROM" || -z "$TO" || ${#FOLDERS[@]} -eq 0 ]]; then
    fail "Usage: $(basename "$0") [--dry-run] --from <kind> --folders <group>... --to <target-dir>"
    exit 1
  fi
  KIND_DIR="$REPO_ROOT/agent/$FROM"
  DST="$(realpath -m "$TO")"

  [[ -d "$KIND_DIR" ]] || { fail "Unknown --from '$FROM' (no $KIND_DIR)"; exit 1; }
  [[ -d "$DST" ]] || { fail "Target dir not found: $DST"; exit 1; }
  _require_all_folders
}

# Report every missing folder at once, before anything is linked.
_require_all_folders() {
  local group missing=()
  for group in "${FOLDERS[@]}"; do
    [[ -d "$KIND_DIR/$group" ]] || missing+=("$group")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    for group in "${missing[@]}"; do fail "Not found in $FROM/: $group"; done
    exit 1
  fi
}

_link_children() {
  local entry name
  for entry in "$SRC"/*; do
    [[ -e "$entry" ]] || continue
    name="${entry##*/}"
    _link_one "$entry" "$DST/$name"
  done
}

_link_one() {
  local src="$1" dst="$2"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    ((SKIPPED++)) || true
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    fail "Already exists, not overwriting: $dst"
    exit 1
  fi

  info "${dst/#$HOME/\~} -> ${src#$REPO_ROOT/}"
  $DRY_RUN || ln -s "$src" "$dst"
  ((LINKED++)) || true
}

# Links into this group whose skill was deleted/renamed in the group.
_prune_dead_links() {
  local link
  for link in "$DST"/*; do
    [[ -L "$link" && ! -e "$link" && "$(readlink "$link")" == "$SRC"/* ]] || continue
    info "Pruning dead link: ${link/#$HOME/\~}"
    $DRY_RUN || rm "$link"
    ((PRUNED++)) || true
  done
}

main
