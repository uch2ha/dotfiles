#!/usr/bin/env bash
set -euo pipefail

# ── Global configuration ───────────────────
WIN_ZED_DIR="Zed"
DOTFILES_ZED_DIR="linux/.config/zed"
SETTINGS_FILE="settings.json"

# ── Derived paths ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOTFILES_SETTINGS="$REPO_ROOT/$DOTFILES_ZED_DIR/$SETTINGS_FILE"

APPDATA_WIN="$(powershell.exe -NoProfile -Command '$env:APPDATA' | tr -d '\r\n')"
WINDOWS_SETTINGS="$(wslpath "$APPDATA_WIN")/$WIN_ZED_DIR/$SETTINGS_FILE"

# ── Sync Windows -> dotfiles ───────────────
[[ -f "$WINDOWS_SETTINGS" ]] || { echo "Not found: $WINDOWS_SETTINGS" >&2; exit 1; }

mkdir -p "$(dirname "$DOTFILES_SETTINGS")"
rsync --archive --checksum "$WINDOWS_SETTINGS" "$DOTFILES_SETTINGS"
echo "Synced: $WINDOWS_SETTINGS -> $DOTFILES_SETTINGS"
