#!/usr/bin/env bash
set -euo pipefail

# NOTE:
# To push to git do: cd ~/.dotfiles && git remote set-url origin git@github.com:uch2ha/dotfiles.git

# GIT
GIT_URL="https://github.com/"
GIT_USER="uch2ha"
GIT_REPO="dotfiles"
REPO_URL="${GIT_URL}${GIT_USER}/${GIT_REPO}.git"
# LOCAL
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_ROOT="$HOME/.setup-zsh-backup"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
CURRENT_BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
# OTHER
OHMYZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

BACKUP_PATHS=(
  "$HOME/.oh-my-zsh"
  "$HOME/.p10k.zsh"
  "$HOME/.zshrc"
  "$HOME/.aliases"
  "$HOME/.dotfiles"
)

REQUIRED_PACKAGES=(
  zsh
  git
  curl
  gpg
)

MISSING_PLUGINS=()

if [[ -t 1 ]]; then
  COLOR_BLUE=$'\033[1;34m'
  COLOR_YELLOW=$'\033[1;33m'
  COLOR_RED=$'\033[1;31m'
  COLOR_GREEN=$'\033[1;32m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_BLUE=''
  COLOR_YELLOW=''
  COLOR_RED=''
  COLOR_GREEN=''
  COLOR_RESET=''
fi


log() {
  printf "${COLOR_BLUE}[INFO] %s${COLOR_RESET}\n" "$*"
}

warn() {
  printf "${COLOR_YELLOW}[WARN] %s${COLOR_RESET}\n" "$*"
}

success() {
  printf "${COLOR_GREEN}[ OK ] %s${COLOR_RESET}\n" "$*"
}

die() {
  printf "${COLOR_RED}[ERROR] %s${COLOR_RESET}\n" "$*" >&2
  exit 1
}


require_sudo() {
  if ! command -v sudo >/dev/null 2>&1; then
    die "sudo is required but not installed."
  fi

  log "Requesting sudo access..."
  sudo -v
  success "sudo access granted"
}


check_supported_system() {
  log "Checking operating system..."

  if [[ ! -f /etc/os-release ]]; then
    die "/etc/os-release not found. Cannot detect Linux distribution."
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  local distro_id="${ID:-}"
  local distro_like="${ID_LIKE:-}"

  if [[ "$distro_id" == "ubuntu" || "$distro_id" == "debian" || "$distro_like" == *"debian"* ]]; then
    success "Supported system detected: ${PRETTY_NAME:-$distro_id}"
  else
    die "Unsupported system: ${PRETTY_NAME:-unknown}. This script supports Debian/Ubuntu only."
  fi
}


prepare_backup_dir() {
  log "Creating backup directory: $CURRENT_BACKUP_DIR"
  mkdir -p "$CURRENT_BACKUP_DIR"
  success "Backup directory created"
}


backup_existing_paths() {
  log "Starting backup of existing files..."

  local path
  local moved_any=false

  for path in "${BACKUP_PATHS[@]}"; do
    if [[ -e "$path" || -L "$path" ]]; then
      local name
      name="$(basename "$path")"

      log "Moving $path -> $CURRENT_BACKUP_DIR/$name"
      mv "$path" "$CURRENT_BACKUP_DIR/$name"
      success "Moved: $path"
      moved_any=true
    else
      warn "Path not found, skipping: $path"
    fi
  done

  if [[ "$moved_any" == false ]]; then
    warn "Nothing to back up, removing empty backup timestamp folder"
    rmdir -- "$CURRENT_BACKUP_DIR"
    success "Removed empty backup directory: $CURRENT_BACKUP_DIR"
  else
    success "Backup completed"
  fi
}


install_required_packages() {
  log "Updating apt package index..."
  sudo apt-get update

  log "Installing required packages: ${REQUIRED_PACKAGES[*]}"
  sudo apt-get install -y "${REQUIRED_PACKAGES[@]}"

  success "Package installation completed"
}


clone_dotfiles_sparse() {
  log "Cloning dotfiles repository with sparse checkout..."

  if [[ -e "$DOTFILES_DIR" ]]; then
    die "Target directory already exists: $DOTFILES_DIR"
  fi

  git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$DOTFILES_DIR"
  cd "$DOTFILES_DIR"

  git sparse-checkout set zsh

  success "Dotfiles repository cloned to $DOTFILES_DIR with only zsh/ checked out"
}


install_apt_packages_from_file() {
  log "Installing additional APT packages from .packages.apt..."

  local package_file="$DOTFILES_DIR/zsh/.packages.apt"
  [[ -f "$package_file" ]] || die "Package list file not found: $package_file"

  local packages=()
  local line

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    packages+=("$line")
  done < "$package_file"

  if [[ ${#packages[@]} -eq 0 ]]; then
    warn "No additional APT packages found in $package_file"
    return
  fi

  log "Installing packages: ${packages[*]}"
  sudo apt-get install -y "${packages[@]}"

  success "Additional APT packages installed"
}


install_oh_my_zsh() {
  log "Installing Oh My Zsh..."

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    die "Expected $HOME/.oh-my-zsh to be absent after backup, but it still exists."
  fi

  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL "$OHMYZSH_INSTALL_URL")" \
    "" --unattended

  [[ -d "$HOME/.oh-my-zsh" ]] || die "Oh My Zsh installation failed: $HOME/.oh-my-zsh was not created."

  success "Oh My Zsh installed"
}


install_powerlevel10k() {
  log "Installing Powerlevel10k theme..."

  local themes_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
  local p10k_dir="$themes_dir/powerlevel10k"

  if [[ -d "$p10k_dir" ]]; then
    log "Powerlevel10k already installed"
    success "Powerlevel10k theme ready"
    return
  fi

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  [[ -d "$p10k_dir" ]] || die "Powerlevel10k installation failed"

  success "Powerlevel10k theme installed"
}


install_eza() {
  log "Installing eza..."

  if command -v eza >/dev/null 2>&1; then
    success "eza is already installed"
    return
  fi

  sudo mkdir -p /etc/apt/keyrings

  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg

  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null

  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

  sudo apt-get update
  sudo apt-get install -y eza

  command -v eza >/dev/null 2>&1 || die "eza installation failed"

  success "eza installed"
}


link_zsh_dotfiles() {
  log "Linking Zsh dotfiles from $DOTFILES_DIR/zsh..."

  local repo_zsh_dir="$DOTFILES_DIR/zsh"
  local src_zshrc="$repo_zsh_dir/.zshrc"
  local src_p10k="$repo_zsh_dir/.p10k.zsh"
  local src_aliases="$repo_zsh_dir/.aliases"

  [[ -d "$repo_zsh_dir" ]] || die "Missing directory: $repo_zsh_dir"
  [[ -f "$src_zshrc" ]] || die "Missing file: $src_zshrc"
  [[ -f "$src_p10k" ]] || die "Missing file: $src_p10k"
  [[ -f "$src_aliases" ]] || die "Missing file: $src_aliases"

  ln -sfn "$src_zshrc" "$HOME/.zshrc"
  success "Linked $HOME/.zshrc -> $src_zshrc"

  ln -sfn "$src_p10k" "$HOME/.p10k.zsh"
  success "Linked $HOME/.p10k.zsh -> $src_p10k"

  ln -sfn "$src_aliases" "$HOME/.aliases"
  success "Linked $HOME/.aliases -> $src_aliases"
}


install_zsh_external_plugins() {
  log "Installing Zsh external plugins..."

  local plugin_list_file="$DOTFILES_DIR/zsh/.plugins.zsh"
  local zshrc_file="$HOME/.zshrc"
  local zsh_custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local plugins_dir="$zsh_custom_dir/plugins"

  [[ -f "$plugin_list_file" ]] || die "Plugin list file not found: $plugin_list_file"
  [[ -f "$zshrc_file" ]] || die ".zshrc not found: $zshrc_file"
  [[ -d "$HOME/.oh-my-zsh" ]] || die "Oh My Zsh must be installed before Zsh external plugins."

  source "$plugin_list_file"

  mkdir -p "$plugins_dir"

  local plugin_repo plugin_name plugin_dir

  for plugin_repo in "${ZSH_CUSTOM_PLUGINS[@]}"; do
    plugin_name="$(basename "$plugin_repo")"
    plugin_dir="$plugins_dir/$plugin_name"

    if [[ -e "$plugin_dir" ]]; then
      log "Plugin already installed: $plugin_name"
    else
      log "Cloning plugin: $plugin_repo"
      git clone --depth=1 "https://github.com/${plugin_repo}.git" "$plugin_dir"
      [[ -d "$plugin_dir" ]] || die "Plugin installation failed: $plugin_dir was not created."
      success "Installed plugin: $plugin_name"
    fi

    if ! grep -qE "plugins=.*\\b${plugin_name}\\b" "$zshrc_file"; then
      MISSING_PLUGINS+=("$plugin_name")
      warn "Plugin '$plugin_name' is installed but not enabled in .zshrc"
    fi
  done

  success "Zsh external plugins installation step completed"
}


set_default_shell_to_zsh() {
  log "Setting Zsh as default login shell..."

  if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "/bin/zsh" ]]; then
    success "Zsh is already your default shell"
    return
  fi

  if ! chsh -s "$(which zsh)" "$USER"; then
    warn "Failed to change default shell automatically."
    warn "Manually run: chsh -s \$(which zsh) $USER"
    warn "Then log out and log back in."
    return
  fi

  success "Zsh set as your default shell"
  success "Log out and log back in (or reboot) for changes to take effect"
}


print_final_summary() {
  cat <<EOF

${COLOR_GREEN}========================================${COLOR_RESET}
${COLOR_GREEN}         Zsh Setup Complete!${COLOR_RESET}
${COLOR_GREEN}========================================${COLOR_RESET}

  Summary:
  - Repo URL:        $REPO_URL
  - Dotfiles dir:    $DOTFILES_DIR
  - Backup created:  $CURRENT_BACKUP_DIR
  - Oh My Zsh:       Installed
  - Theme:           Powerlevel10k
EOF
}


print_missing_plugins() {
  if [[ ${#MISSING_PLUGINS[@]} -eq 0 ]]; then
    return
  fi

  printf "\n${COLOR_RED}[WARN] Plugins installed but missing in .zshrc:${COLOR_RESET}\n"
  local plugin
  for plugin in "${MISSING_PLUGINS[@]}"; do
    printf "${COLOR_RED}  - %s${COLOR_RESET}\n" "$plugin"
  done

  printf "\n${COLOR_YELLOW}Add them to plugins=(...) in %s${COLOR_RESET}\n" "$HOME/.zshrc"
}


main() {
  check_supported_system
  require_sudo
  prepare_backup_dir
  backup_existing_paths
  install_required_packages
  clone_dotfiles_sparse
  install_oh_my_zsh
  install_powerlevel10k
  install_eza
  link_zsh_dotfiles
  install_zsh_external_plugins
  set_default_shell_to_zsh
  print_final_summary
  print_missing_plugins
}

main "$@"
