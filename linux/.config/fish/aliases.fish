if type -q eza
  alias ls="eza"
  alias ll="eza --long --icons"
  alias la="eza --long --all --icons"
end

if type -q bat
  alias cat="bat"
end

if type -q zoxide
  alias cd="z"
end
