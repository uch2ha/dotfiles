# Enable Powerlevel10k instant prompt (must stay near the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh update behavior: remind me when updates are available
zstyle ':omz:update' mode reminder

# Enable automatic command correction
ENABLE_CORRECTION="true"

# History timestamp format: yyyy-mm-dd
HIST_STAMPS="yyyy-mm-dd"

# Disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Load Powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load plugins (built-in + external)
plugins=( git z zsh-syntax-highlighting zsh-autosuggestions )

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Source custom aliases
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Load nvm (Node.js version manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
