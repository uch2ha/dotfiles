# ── Colors ─────────────────────────────────
if [[ -t 1 ]]; then
  RST=$'\033[0m'; YLW=$'\033[1;33m';
  RED=$'\033[1;31m'; GRN=$'\033[1;32m'; BLD=$'\033[1;34m';
  GRY=$'\033[0;90m';
else
  BLD=''; YLW=''; RED=''; GRN=''; RST=''; GRY='';
fi

# ── Logs ───────────────────────────────────
info()    { printf "${BLD}[INFO]${RST}${GRY}${SECTION:+ ($SECTION)}${RST} %s\n" "$*"; }
warn()    { printf "${YLW}[WARN]${RST}${GRY}${SECTION:+ ($SECTION)}${RST} %s\n" "$*"; }
fail()    { printf "${RED}[FAIL]${RST}${GRY}${SECTION:+ ($SECTION)}${RST} %s\n" "$*"; }
success() { printf "${GRN}[ OK ]${RST}${GRY}${SECTION:+ ($SECTION)}${RST} %s\n" "$*"; }

# ── Helpers ────────────────────────────────
request_sudo() {
  if ! command -v sudo &>/dev/null; then
    fail "sudo is required but not installed."
    exit 1
  fi
  info "Requesting sudo access..."
  sudo -v
}
