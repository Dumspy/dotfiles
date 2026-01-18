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
  
  # Remove lines that reference /nix/store paths directly
  echo "$tmp_content" | grep -v '/nix/store' > "$tmp" || true
  
  # Replace nix store references with comments
  sed -i \
    -e 's|HELPDIR="/nix/store/[^"]*-zsh-[^"]*/share/zsh/\$ZSH_VERSION/help"|# HELPDIR removed - install zsh system package|g' \
    -e 's|source /nix/store/[^-]*-zsh-autosuggestions-[^/]*/share/zsh-autosuggestions/zsh-autosuggestions.zsh|# Autosuggestions: install via package manager or download|g' \
    "$tmp" 2>/dev/null || true
  
  # Preserve the file if it has content after sanitization
  if [[ -s "$tmp" ]]; then
    cat "$tmp" > "$file"
    rm -f "$tmp"
  else
    rm -f "$tmp"
  fi
}

# Sanitize shell files
for shellfile in "$OUTPUT_DIR"/.zshrc "$OUTPUT_DIR"/.bashrc; do
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

echo "✓ Sanitization complete"
