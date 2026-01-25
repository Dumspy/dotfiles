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

  local tmp
  tmp=$(mktemp)
  
  # First, replace known nix store paths with portable equivalents
  cat "$file" > "$tmp"
  sed -i \
    -e 's|HELPDIR="/nix/store/[^"]*-zsh-[^"]*/share/zsh/\$ZSH_VERSION/help"|# HELPDIR removed - install zsh system package|g' \
    -e 's|source /nix/store/[^-]*-zsh-autosuggestions-[^/]*/share/zsh-autosuggestions/zsh-autosuggestions.zsh|# Autosuggestions: install via package manager or download|g' \
    -e "s|source '/nix/store/[^']*-catppuccin-zsh-syntax-highlighting[^']*'|# Catppuccin syntax highlighting: install manually if desired|g" \
    -e 's|/nix/store/[^/]*/bin/\([a-zA-Z0-9_-]*\)|\1|g' \
    -e 's|run-shell /nix/store/[^[:space:]]*tmuxplugin-catppuccin[^[:space:]]*|# Catppuccin: install via TPM or manually|g' \
    -e 's|run-shell /nix/store/[^[:space:]]*tmuxplugin-sensible[^[:space:]]*|# Sensible: install via TPM or manually|g' \
    -e 's|run-shell /nix/store/[^[:space:]]*tmuxplugin-vim-tmux-navigator[^[:space:]]*|# Vim-tmux-navigator: install via TPM or manually|g' \
    "$tmp" 2>/dev/null || true
  
  # Remove lines with nix store paths, NIX_PROFILES references, or home-manager completions path
  grep -v -E '/nix/store|NIX_PROFILES|\$\{.*NIX_PROFILES|home-manager/generated_completions' "$tmp" > "${tmp}.filtered" || true
  mv "${tmp}.filtered" "$tmp"
  
  # Remove orphaned fpath lines from NIX_PROFILES loop (zsh-specific)
  sed -i '/fpath+=(\$profile\/share\/zsh/d' "$tmp" 2>/dev/null || true
  
  # Remove standalone 'done' that appears right after typeset line (orphaned from NIX_PROFILES loop)
  # This is a specific pattern: "typeset ... done" with nothing in between
  sed -i ':a;N;$!ba;s/\(typeset -U path cdpath fpath manpath\n\)done\n/\1/g' "$tmp" 2>/dev/null || true
  
  # Replace hardcoded /home/user with $HOME (do it per-file for safety)
  sed -i 's|/home/user|\$HOME|g' "$tmp" 2>/dev/null || true
  
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

# Remove Nix-specific files/directories that don't make sense for portable
echo "Removing Nix-specific files and directories..."
rm -rf "$OUTPUT_DIR"/.manpath
rm -rf "$OUTPUT_DIR"/.zshenv
rm -rf "$OUTPUT_DIR"/.cache
rm -rf "$OUTPUT_DIR"/.local/state
rm -rf "$OUTPUT_DIR"/.config/systemd
rm -rf "$OUTPUT_DIR"/.config/environment.d
rm -rf "$OUTPUT_DIR"/.local/share/fish/home-manager
rm -rf "$OUTPUT_DIR"/.local/share/nvim/site/pack/hm

# Remove empty directories
find "$OUTPUT_DIR" -type d -empty -delete 2>/dev/null || true

echo "✓ Sanitization complete"
