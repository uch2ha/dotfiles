#!/usr/bin/env bash
# SessionStart hook: inject global + project AGENTS.md into Claude's context (stdout -> context).
set -u
cat >/dev/null 2>&1 || true  # drain hook JSON from stdin

emit() { [ -f "$1" ] && { printf '\n# AGENTS.md (%s)\n\n' "$2"; cat "$1"; printf '\n'; }; }

emit "$HOME/.claude/AGENTS.md" "global"

# Walk up from cwd to the git root (or filesystem root), take the nearest AGENTS.md.
dir="$PWD"
while :; do
  if [ -f "$dir/AGENTS.md" ] && [ "$dir/AGENTS.md" != "$HOME/.claude/AGENTS.md" ]; then
    emit "$dir/AGENTS.md" "project: $dir/AGENTS.md"
    break
  fi
  { [ -e "$dir/.git" ] || [ "$dir" = "/" ] || [ "$dir" = "$HOME" ]; } && break
  dir="$(dirname "$dir")"
done
exit 0
