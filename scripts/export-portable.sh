#!/usr/bin/env bash
set -euo pipefail

# Export portable dotfiles configuration
# Usage: ./scripts/export-portable.sh [output-dir]

OUTPUT_DIR="${1:-.}/stow"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building portable home-manager configuration..."
GEN_PATH=$(nix build .#homeConfigurations.portable.activationPackage --no-link --print-out-paths)

echo "Exporting dotfiles..."
mkdir -p "$OUTPUT_DIR"
cp -rL "$GEN_PATH/home-files/." "$OUTPUT_DIR/"

echo "Sanitizing Nix store references..."
"$SCRIPT_DIR/sanitize-dotfiles.sh" "$OUTPUT_DIR"

echo "✓ Portable dotfiles exported to $OUTPUT_DIR"
echo ""
echo "To use with stow:"
echo "  stow -d $OUTPUT_DIR -t ~ ."
