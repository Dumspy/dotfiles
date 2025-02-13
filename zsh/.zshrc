# Starship
export STARSHIP_CONFIG=~/.config/starship.toml

eval "$(starship init zsh)"

# pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init - zsh)"

# fzf
source <(fzf --zsh)

# zsh_profile
source ~/.zsh_profile

#direnv
eval "$(direnv hook zsh)"

if [[ "$(uname -n)" == "nixos" ]]; then
  source ~/.ssh_pipe
fi

alias ns='nix-shell --command $SHELL'