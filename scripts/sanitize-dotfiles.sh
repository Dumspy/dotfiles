#!/usr/bin/env bash
set -euo pipefail

# Sanitize portable dotfiles: strip Nix store references
# Usage: ./scripts/sanitize-dotfiles.sh <input-dir> [output-dir]

INPUT_DIR="${1:?Input directory required}"
OUTPUT_DIR="${2:-$INPUT_DIR}"

if [[ "$INPUT_DIR" != "$OUTPUT_DIR" ]]; then
  echo "Sanitizing dotfiles from $INPUT_DIR to $OUTPUT_DIR..."
  mkdir -p "$OUTPUT_DIR"
  cp -rL "$INPUT_DIR/." "$OUTPUT_DIR/"
else
  echo "Sanitizing dotfiles in $INPUT_DIR..."
fi

# Make all files writable
chmod -R u+w "$OUTPUT_DIR" 2>/dev/null || true

# Function to sanitize a file
sanitize_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return
  fi

  local tmp tmp_content
  tmp=$(mktemp)
  tmp_content=$(cat "$file" || true)
  
  # Remove lines that reference /nix/store paths or Nix-specific variables
  echo "$tmp_content" | grep -v -E '/nix/store|NIX_PROFILES' > "$tmp" || true
  
  # Replace nix store references with comments
  sed -i \
    -e 's|HELPDIR="/nix/store/[^"]*-zsh-[^"]*/share/zsh/\$ZSH_VERSION/help"|# HELPDIR removed - install zsh system package|g' \
    -e 's|source /nix/store/[^-]*-zsh-autosuggestions-[^/]*/share/zsh-autosuggestions/zsh-autosuggestions.zsh|# Autosuggestions: install via package manager or download|g' \
    "$tmp" 2>/dev/null || true
  
  # Always overwrite: if empty after sanitization, truncate the file
  cat "$tmp" > "$file"
  rm -f "$tmp"
}

# Sanitize shell files
for shellfile in "$OUTPUT_DIR"/.zshrc "$OUTPUT_DIR"/.bashrc "$OUTPUT_DIR"/.zshenv; do
  if [[ -f "$shellfile" ]]; then
    sanitize_file "$shellfile"
  fi
done

# Sanitize config files
if [[ -d "$OUTPUT_DIR"/.config ]]; then
  find "$OUTPUT_DIR"/.config -type f | while read -r file; do
    sanitize_file "$file"
  done
fi

# Sanitize local files
if [[ -d "$OUTPUT_DIR"/.local ]]; then
  find "$OUTPUT_DIR"/.local -type f | while read -r file; do
    sanitize_file "$file"
  done
fi

# Remove Nix-specific files that don't make sense for portable
rm -f "$OUTPUT_DIR"/.manpath

# Replace hardcoded /home/user with $HOME
find "$OUTPUT_DIR" -type f | while read -r file; do
  if grep -q '/home/user' "$file" 2>/dev/null; then
    sed -i 's|/home/user|\$HOME|g' "$file"
  fi
done

echo "✓ Sanitization complete"
