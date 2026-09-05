#!/usr/bin/env bash
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT


# ── Derived paths ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Inject ─────────────────────────────────
source "$SCRIPT_DIR/_lib.sh"
SECTION="d-fish"

# ── CLI flags ──────────────────────────────
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

main() {
  if ! command -v fish &>/dev/null; then
    fail "fish is not installed. Run install-packages.sh first."
    exit 1
  fi

  request_sudo

  info "Setting fish as default shell..."
  if $DRY_RUN; then
    info "Dry run: would run: sudo usermod --shell $(command -v fish) $USER"
  else
    sudo usermod --shell "$(command -v fish)" "$USER"
    success "Default shell changed to fish"
    warn "Log out and back in for the change to take effect"
  fi
}

main "$@"
