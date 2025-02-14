# Starship
export STARSHIP_CONFIG=~/.config/starship.toml

eval "$(starship init zsh)"

# fzf
source <(fzf --zsh)

# zsh_profile
source ~/.zsh_profile

#direnv
eval "$(direnv hook zsh)"

if [[ "$(uname -n)" == "nixos" ]]; then
  source ~/.ssh_pipe
fi