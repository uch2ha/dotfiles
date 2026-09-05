#!/usr/bin/env bash
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT


# ── Global configuration ───────────────────
PACKAGES_FILE=".packages"
SUPPORTED_DISTRO="fedora"
SUPPORTED_MANAGER="dnf"

# ── Derived paths ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGES_ABS="$REPO_ROOT/$PACKAGES_FILE"

# ── Inject ─────────────────────────────────
source "$SCRIPT_DIR/_lib.sh"
SECTION="i-packages"

# ── Shared state ───────────────────────────
declare -ga INSTALL_OK=()
declare -ga INSTALL_FAIL=()

declare -g OS=""
declare -g MANAGER=""

main() {
  if [[ ! -f "$PACKAGES_ABS" ]]; then
    warn "Packages file not found: $PACKAGES_FILE"
    exit 0
  fi

  OS="$(detect_os)"
  MANAGER="$(resolve_package_manager)"

  info "Detected OS: $OS"
  info "Package manager: $MANAGER"

  if [[ "$OS" != "$SUPPORTED_DISTRO" ]]; then
    fail "Unsupported distro: $OS (expected $SUPPORTED_DISTRO)"
    exit 1
  fi

  request_sudo

  local sections
  sections="$(resolve_sections)"

  local total_packages=0
  while IFS= read -r section; do
    [[ -z "$section" ]] && continue

    info "Processing section: [$section]"

    while IFS= read -r pkg_line; do
      [[ -z "$pkg_line" ]] && continue
      for pkg in $pkg_line; do
        total_packages=$((total_packages + 1))
        install_package "$pkg" "$MANAGER"
      done
    done < <(parse_section "$section" "$PACKAGES_ABS")
  done <<< "$sections"

  log_summary

  if [[ ${#INSTALL_FAIL[@]} -gt 0 ]]; then
    return 1
  fi
}

detect_os() {
  if [[ ! -f /etc/os-release ]]; then
    fail "Could not detect operating system."
    exit 1
  fi
  # shellcheck disable=SC1091
  source /etc/os-release
  echo "$ID"
}

resolve_package_manager() {
  echo "$SUPPORTED_MANAGER"
}

parse_section() {
  local section="$1"
  local file="$2"
  local in_section=false

  while IFS= read -r line; do
    line="${line%%#*}"             # strip inline comments
    line="${line#"${line%%[![:space:]]*}"}"   # trim leading space
    line="${line%"${line##*[![:space:]]}"}"   # trim trailing space
    [[ -z "$line" ]] && continue

    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      if $in_section; then break; fi
      [[ "${BASH_REMATCH[1]}" == "$section" ]] && in_section=true || in_section=false
    elif $in_section; then
      echo "$line"
    fi
  done < "$file"
}

install_package() {
  local package="$1"

  if sudo "$MANAGER" install -y "$package"; then
    INSTALL_OK+=("$package")
  else
    INSTALL_FAIL+=("$package"); return 1
  fi
}

log_summary() {
  if [[ ${#INSTALL_OK[@]} -gt 0 ]]; then
    success "Installed ${#INSTALL_OK[@]} package(s)"
    for pkg in "${INSTALL_OK[@]}"; do
      success "$pkg"
    done
  fi

  if [[ ${#INSTALL_FAIL[@]} -gt 0 ]]; then
    fail "Failed ${#INSTALL_FAIL[@]} package(s)"
    for pkg in "${INSTALL_FAIL[@]}"; do
      fail "$pkg"
    done
  fi

  if [[ ${#INSTALL_OK[@]} -eq 0 && ${#INSTALL_FAIL[@]} -eq 0 ]]; then
    info "No packages to install."
  fi
}

resolve_sections() {
  echo "$SUPPORTED_DISTRO"
}

main "$@"
