declare -A systems
systems=(
  ["wsl"]="nixos-rebuild switch --flake $HOME/dotfiles/nix#wsl"
  ["docker-host"]="nixos-rebuild switch --flake $HOME/dotfiles/nix#docker-host"
  ["Felixs-MacBook-Air"]="nix-darwin switch --flake $HOME/dotfiles/nix#Felixs-MacBook-Air"
)

selected=$(printf "%s\n" "${!systems[@]}" | fzf --prompt="Select system to rebuild: ")

if [[ -n "$selected" ]]; then
  command=${systems[$selected]}
  eval "sudo $command"
else
  echo "No system selected."
fi