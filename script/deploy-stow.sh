#!/usr/bin/env bash
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT


# ── Global configuration ───────────────────
STOW_DIR="linux"
TARGET_DIR="$HOME"

# ── Derived paths ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_ABS="$REPO_ROOT/$STOW_DIR"

# ── Inject ─────────────────────────────────
source "$SCRIPT_DIR/_lib.sh"
SECTION="d-stow"

# ── CLI flags ──────────────────────────────
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

main() {
  if ! command -v stow &>/dev/null; then
    fail "stow is not installed"
    exit 1
  fi

  if [[ ! -d "$STOW_ABS" ]]; then
    warn "Stow directory not found: $STOW_DIR"
    exit 0
  fi

  info "Stowing $STOW_ABS -> $TARGET_DIR"
  printf "\n"

  local stow_args=(--verbose 2 --no-folding)
  $DRY_RUN && stow_args+=(--no)

  cd "$REPO_ROOT"

  if ! stow "${stow_args[@]}" -d "$STOW_DIR" -t "$TARGET_DIR" . 2>&1; then
    printf "\n"
    warn "stow encountered conflicts. Run backup.sh first or check what files are in the way."
    exit 1
  fi

  printf "\n"
  if $DRY_RUN; then
    info "Dry run: no changes will be made"
  else
    success "Symlinks deployed successfully"
  fi
}

main "$@"
