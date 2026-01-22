#!/usr/bin/env bash
set -euo pipefail

# Script to update pinned non-flake inputs in flake.nix
# Usage: update-pinned-inputs.sh <input-name>

name="$1"

# Outputs are written to GITHUB_OUTPUT if available
output_var="${GITHUB_OUTPUT:-/dev/stdout}"

echo "Updating pinned input $name..."

# Get current owner and ref from flake.lock
current_owner=$(jq -r ".nodes[\"$name\"].locked.owner" flake.lock)
current_rev=$(jq -r ".nodes[\"$name\"].locked.rev" flake.lock)
echo "Current revision: $current_rev"

# Temporarily replace pinned commit with branch reference
sed -i "s|url = \"github:[^\"]*/${name}/[^\"]*\";|url = \"github:${current_owner}/${name}?ref=main\";|" flake.nix

# Update the input
if ! nix flake update "$name"; then
  echo "::error::Failed to update $name"
  exit 1
fi

# Get new revision from flake.lock
new_rev=$(jq -r ".nodes[\"$name\"].locked.rev" flake.lock)
new_owner=$(jq -r ".nodes[\"$name\"].locked.owner" flake.lock)

echo "New revision for $name: $new_rev"

# Check if there were actual changes
if [ "$new_rev" = "$current_rev" ]; then
  echo "No changes detected"
  # Revert flake.nix back to pinned state
  sed -i "s|url = \"github:[^\"]*/${name}[^\"]*\";|url = \"github:${current_owner}/${name}/${current_rev}\";|" flake.nix
  if [ "${GITHUB_OUTPUT:-}" ]; then
    echo "updated=false" >>"$output_var"
  fi
  exit 0
fi

# Update flake.nix with new pinned commit
sed -i "s|url = \"github:[^\"]*/${name}[^\"]*\";|url = \"github:${new_owner}/${name}/${new_rev}\";|" flake.nix

# Format flake.nix
alejandra flake.nix

echo "updated=true" >>"$output_var"
echo "old_version=$current_rev" >>"$output_var"
echo "new_version=$new_rev" >>"$output_var"