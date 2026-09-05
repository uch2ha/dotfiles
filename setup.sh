#!/usr/bin/env bash
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT


# ── Global configuration ───────────────────
REPO_URL="https://github.com/uch2ha/dotfiles.git"
CLONE_DIR="dotfiles"

STEPS=(
  backup
  install-packages
  deploy-*
)

main() {
  check_git
  check_existing
  check_pwd
  request_sudo_preclone
  clone_repo

  cd "$CLONE_DIR"

  success "Dotfiles repo cloned"

  local -a expanded
  expand_steps expanded
  run_steps expanded
  print_summary "${expanded[@]}"
}

expand_steps() {
  local -n out="$1"
  shopt -s nullglob
  local step
  for step in "${STEPS[@]}"; do
    if [[ "$step" == deploy-* ]]; then
      local pattern="script/${step/\*}.sh"
      local f
      for f in $pattern; do
        out+=("$(basename "$f" .sh)")
      done
    else
      out+=("$step")
    fi
  done
}

run_steps() {
  local -a steps=("$@")
  local s
  for s in "${steps[@]}"; do
    local step_file="script/$s.sh"
    if [[ ! -x "$step_file" ]]; then
      warn "Step not found or not executable: $step_file — skipping"
      continue
    fi
    info "Running: $s"
    if ! "$step_file"; then
      fail "Step failed: $s"
      exit 1
    fi
    printf "\n"
  done
}

print_summary() {
  local -a steps=("$@")
  success "Setup complete"

  for s in "${steps[@]}"; do
    success "$s"
  done

  local found_backup=false
  local s
  for s in "${steps[@]}"; do
    [[ "$s" == "backup" ]] && found_backup=true && break
  done
  if $found_backup; then
    local latest
    latest="$(ls -dt _backup/*/ 2>/dev/null | head -1)"
    [[ -n "$latest" ]] && info "Backup created: $latest"
  fi

  printf "\n"
}

# ── Pre-clone helpers ──────────────────────
check_git() {
  if ! command -v git &>/dev/null; then
    fail "git is required but not installed."
    exit 1
  fi
}

check_existing() {
  if [[ -d "$CLONE_DIR" ]]; then
    warn "$CLONE_DIR already exists in $PWD. Remove or move it first, then retry."
    exit 1
  fi
}

check_pwd() {
  if [[ "$PWD" != "$HOME" ]]; then
    warn "Recommended: run from your home directory ($HOME)"
    info "Current: $PWD"
    read -r -p "Continue here? [y/N] " yn
    [[ "$yn" =~ ^[yY] ]] || exit 0
  fi
}

request_sudo_preclone() {
  if ! command -v sudo &>/dev/null; then
    fail "sudo is required but not installed."
    exit 1
  fi
  info "Requesting sudo access..."
  sudo -v
}

clone_repo() {
  printf "\n"
  info "Cloning $REPO_URL to $CLONE_DIR ..."
  git clone "$REPO_URL" "$CLONE_DIR"
}

# ── Colors & log helpers ───────────────────
if [[ -t 1 ]]; then
  BLD=$'\033[1;34m'; YLW=$'\033[1;33m'
  RED=$'\033[1;31m'; GRN=$'\033[1;32m'; RST=$'\033[0m'
else
  BLD=''; YLW=''; RED=''; GRN=''; RST=''
fi

SECTION="main"
info()    { printf "${BLD}[INFO]${RST}${SECTION:+ ($SECTION)} %s\n" "$*"; }
warn()    { printf "${YLW}[WARN]${RST}${SECTION:+ ($SECTION)} %s\n" "$*"; }
fail()    { printf "${RED}[FAIL]${RST}${SECTION:+ ($SECTION)} %s\n" "$*"; }
success() { printf "${GRN}[ OK ]${RST}${SECTION:+ ($SECTION)} %s\n" "$*"; }

main "$@"
