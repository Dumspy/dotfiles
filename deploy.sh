#!/usr/bin/env bash

declare -A systems
systems=(
  ["k3s-node"]="k3s-node"
  ["master-node"]="master-node"
  ["oci-node-1"]="oci-node-1"
  ["oci-node-2"]="oci-node-2"
  ["oci-node-3"]="oci-node-3"
)

# Determine systems to deploy
if [[ -n "$NIX_HOST" && -n "${systems[$NIX_HOST]}" ]]; then
  selected=("${systems[$NIX_HOST]}")
elif [[ -n "${systems[$(hostname)]}" ]]; then
  selected=("${systems[$(hostname)]}")
else
  mapfile -t selected < <(printf "%s\n" "${!systems[@]}" | fzf --multi --prompt="Select systems to deploy: ")
fi

if [[ ${#selected[@]} -gt 0 ]]; then
  if [[ ${#selected[@]} -eq 1 ]]; then
    echo "Deploying to: ${selected[*]}"
    nix run github:serokell/deploy-rs -- --skip-checks ".#${selected[0]}"
  else
    echo "Deploying to: ${selected[*]}"
    targets=$(printf ".#%s " "${selected[@]}")
    nix run github:serokell/deploy-rs -- --skip-checks --targets $targets
  fi
else
  echo "No systems selected."
fi
