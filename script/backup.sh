#!/usr/bin/env bash
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT


# ── Global configuration ───────────────────
SOURCE_DIR="linux"
BACKUP_DIR="_backup"
LOG_DIR_DEPTH=2

# ── Derived paths ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_ABS="$REPO_ROOT/$SOURCE_DIR"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
BACKUP_ABS="$REPO_ROOT/$BACKUP_DIR/$TIMESTAMP"

# ── Inject ─────────────────────────────────
source "$SCRIPT_DIR/_lib.sh"
SECTION="backup"

# ── CLI flags ──────────────────────────────
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Shared state ───────────────────────────
declare -gA DIR_COUNTS
declare -gi TOTAL=0
declare -gi SYMLINKS_FOUND=0

main() {
  if [[ ! -d "$SOURCE_ABS" ]]; then
    warn "Source directory not found: $SOURCE_DIR"
    exit 0
  fi

  info "Scanning /$SOURCE_DIR for files to backup..."
  info "Backup destination: /$BACKUP_DIR/$TIMESTAMP/"

  $DRY_RUN && info "DRY RUN — no files will be moved"

  warn_about_symlinks_in_source
  process_all_backups
  log_summary
}

warn_about_symlinks_in_source() {
  while IFS= read -r -d '' sym; do
    rel="${sym#$SOURCE_ABS/}"
    warn "Symlink in source, skipping: $SOURCE_DIR/$rel"
    ((SYMLINKS_FOUND++)) || true
  done < <(find "$SOURCE_ABS" -type l -print0 2>/dev/null || true)
}

process_all_backups() {
  while IFS= read -r -d '' file; do
    rel_path="${file#$SOURCE_ABS/}"
    _backup_single_file "$rel_path"
  done < <(find "$SOURCE_ABS" -type f -print0 2>/dev/null || true)
}

_backup_single_file() {
  local rel_path="$1"
  local file="$SOURCE_ABS/$rel_path"
  local target="$HOME/$rel_path"

  [[ -e "$target" ]] || return 0
  _already_managed_by_stow "$target" "$file" && return

  local backup_path="$BACKUP_ABS/$rel_path"
  local backup_dir="$(dirname "$backup_path")"

  if $DRY_RUN; then
    info "[DRY-RUN] Would move: $target -> $BACKUP_DIR/$TIMESTAMP/$rel_path"
  else
    mkdir -p "$backup_dir"
    mv "$target" "$backup_path"
  fi

  _record_dir_count "$rel_path"
  ((TOTAL++)) || true
}

_already_managed_by_stow() {
  local target="$1"
  local file="$2"
  [[ -L "$target" ]] || return 1
  local real_target real_source
  real_target="$(realpath "$target" 2>/dev/null || readlink -f "$target")"
  real_source="$(realpath "$file" 2>/dev/null || readlink -f "$file")"
  [[ "$real_target" == "$real_source" ]]
}

_record_dir_count() {
  local rel_path="$1"
  local rel_dir="$(dirname "$rel_path")"

  if [[ "$rel_dir" == "." ]]; then
    DIR_COUNTS["(root)"]=$(( ${DIR_COUNTS["(root)"]-0} + 1 ))
    return
  fi

  IFS='/' read -ra parts <<< "$rel_dir"
  local depth_key=""
  for ((i=0; i<LOG_DIR_DEPTH && i<${#parts[@]}; i++)); do
    depth_key+="${parts[$i]}/"
  done
  depth_key="${depth_key%/}"
  DIR_COUNTS["$depth_key"]=$(( ${DIR_COUNTS["$depth_key"]-0} + 1 ))
}

log_summary() {
  if [[ $TOTAL -eq 0 && $SYMLINKS_FOUND -eq 0 ]]; then
    success "Nothing to backup — all targets are already managed or don't exist"
    return
  fi

  if [[ $TOTAL -gt 0 ]]; then
    success "Backed up ${TOTAL} file(s) to ${BACKUP_DIR}/${TIMESTAMP}/"

    mapfile -t sorted_keys < <(printf '%s\n' "${!DIR_COUNTS[@]}" | sort)
    local pad_width=15
    for key in "${sorted_keys[@]}"; do
      local count="${DIR_COUNTS[$key]}"
      local label="$(printf '%-*s' "$pad_width" "$key")"
      info "$label  ${count} file(s)"
    done
  fi

  if [[ $SYMLINKS_FOUND -gt 0 ]]; then
    warn "Skipped ${SYMLINKS_FOUND} symlink(s) in source (not backed up)"
  fi
}

main "$@"
