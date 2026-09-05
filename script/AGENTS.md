# script/

Setup pipeline scripts called by `setup.sh`. Each script is a single step.

## Boilerplate (every script)

```bash
#!/usr/bin/env bash
set -euo pipefail
trap 'echo; echo "ABORTED by user"; exit 130' INT
```

## Structure

- `main()` at top of file (after boilerplate + sections), calls small sub-methods
- Sub-methods are small, single-responsibility. Sub-methods calls private helper methods
- Private helpers prefixed with `_` (e.g. `_backup_single_file`)

## Logging

Always use `info()`, `warn()`, `fail()`, `success()` from `_lib.sh` — never raw `echo` for logging.

## Patterns

- `--dry-run` flag where destructive — check `$DRY_RUN` before `mv`/`rm`/`sudo` operations
- Exit non-zero on failure — `setup.sh` halts on any non-zero exit
- `request_sudo` from `_lib.sh`, at start of script if any `sudo` calls are needed

## Adding a step

1. Create `script/<name>.sh` following conventions above
2. Add `"<name>"` or `"<prefix>-*"` to `STEPS` array in `setup.sh`
3. If logic is reusable in 2+ scripts, move to `_lib.sh`

## Top Section order (skip what's not needed)

```
# ── Global configuration ───────────────────
# ── Derived paths ──────────────────────────
# ── Inject ─────────────────────────────────
# ── CLI flags ──────────────────────────────
# ── Shared state ───────────────────────────
```

- **Global configuration** — user-facing vars that could change (dirs, file names, flags)
- **Derived paths** — computed from `BASH_SOURCE[0]` inline in every script:
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  ```
  Must come **before** Inject, because `source "$SCRIPT_DIR/_lib.sh"` needs `$SCRIPT_DIR`.
- **Inject** — `source "$SCRIPT_DIR/_lib.sh"` then `SECTION="<name>"`
- **CLI flags** — `while [[ $# -gt 0 ]]; do` block, parse to vars
- **Shared state** — `declare -g` vars used across functions within the script

## Shared state conventions

| Pattern             | When to use                                          |
| ------------------- | ---------------------------------------------------- |
| `myvar=x`           | Simple flag or single value, set at top level        |
| `declare -g VAR`    | Global shared across functions (inside any function) |
| `declare -ga ARRAY` | Global indexed array (list of items)                 |
| `declare -gA MAP`   | Global associative array (key→value pairs)           |
| `declare -gi COUNT` | Global integer (arithmetic, typed)                   |

Rules:

- Outside functions, `declare` without `-g` is fine (already global) — `-g` is just explicit
- Inside functions, always use `-g` if the var should live beyond the function call
- `-gi` enables arithmetic context: `((COUNT++))` works without `$`
