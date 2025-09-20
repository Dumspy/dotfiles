#!/usr/bin/env bash

declare -A systems
systems=(
  ["wsl-devbox"]="nixos-rebuild switch --flake $HOME/dotfiles/nix#wsl-devbox"
  ["darwin"]="darwin-rebuild switch --flake $HOME/dotfiles/nix#dariwn"
  ["k3s-node"]="nixos-rebuild switch --flake $HOME/dotfiles/nix#k3s-node"
  ["master-node"]="nixos-rebuild switch --flake $HOME/dotfiles/nix#master-node"
)


# Determine system selection
if [[ -n "$NIX_HOST" && -n "${systems[$NIX_HOST]}" ]]; then
  selected="$NIX_HOST"
elif [[ -n "${systems[$(hostname)]}" ]]; then
  selected="$(hostname)"
else
  selected=$(printf "%s\n" "${!systems[@]}" | fzf --prompt="Select system to rebuild: ")
fi

if [[ -n "$selected" ]]; then
  git add -f $HOME/dotfiles/nix/secrets/secrets.enc.yaml
  command=${systems[$selected]}
  if [[ "$selected" == "darwin" ]]; then
    eval "$command"
  else
    eval "sudo $command"
  fi
  git restore --staged $HOME/dotfiles/nix/secrets/secrets.enc.yaml
else
  echo "No system selected."
fi