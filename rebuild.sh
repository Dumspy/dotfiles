declare -A systems
systems=(
  ["wsl"]="nixos-rebuild switch --flake $HOME/dotfiles/nix#wsl"
  ["Felixs-MacBook-Air"]="nix-darwin switch --flake $HOME/dotfiles/nix#Felixs-MacBook-Air"
  ["docker-host"]="nixos-rebuild switch --flake $HOME/dotfiles/nix#docker-host"
  ["docker-host-remote"]="nixos-rebuild --use-remote-sudo --build-host nixos@192.168.1.202 --target-host nixos@192.168.1.202 switch --flake $HOME/dotfiles/nix#docker-host"
)

selected=$(printf "%s\n" "${!systems[@]}" | fzf --prompt="Select system to rebuild: ")

if [[ -n "$selected" ]]; then
  command=${systems[$selected]}
  eval "sudo $command"
else
  echo "No system selected."
fi