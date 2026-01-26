#!/usr/bin/env bash
set -euo pipefail

# Bootstrap portable dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/Dumspy/dotfiles/portable/bootstrap.sh | bash

REPO_URL="https://github.com/Dumspy/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BRANCH="portable"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1" >&2; }

# Check prerequisites
check_prerequisites() {
  if ! command -v git &>/dev/null; then
    error "git is required but not installed."
    exit 1
  fi
 
  if ! command -v stow &>/dev/null; then
    error "stow is required but not installed."
    echo ""
    echo "Install with your package manager:"
    echo "  Ubuntu/Debian: sudo apt install stow"
    echo "  macOS:         brew install stow"
    echo "  Fedora:        sudo dnf install stow"
    echo "  Arch:          sudo pacman -S stow"
    exit 1
  fi
  
  # Check for recommended tools (warnings only)
  if ! command -v tmux &>/dev/null; then
    warn "tmux not found. Install with: brew install tmux"
  fi
  
  if ! command -v nvim &>/dev/null; then
    warn "nvim not found. Install with: brew install nvim"
  fi
}

# Install zsh plugins via GitHub clone
install_zsh_plugins() {
  info "Installing zsh plugins..."
  
  local plugins_dir="$HOME/.local/share/zsh/plugins"
  mkdir -p "$plugins_dir"
  
  # zsh-autosuggestions
  if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
    info "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$plugins_dir/zsh-autosuggestions"
  else
    info "Updating zsh-autosuggestions..."
    (cd "$plugins_dir/zsh-autosuggestions" && git pull)
  fi
  
  # fzf-tab (optional - not installed by default)
  # Uncomment below to install fzf-tab
  # if [[ ! -d "$plugins_dir/fzf-tab" ]]; then
  #   info "Cloning fzf-tab..."
  #   git clone https://github.com/Aloxaf/fzf-tab.git "$plugins_dir/fzf-tab"
  # fi
  
  info "✓ zsh plugins installed"
}

# Install TPM (tmux plugin manager)
install_tpm() {
  info "Installing TPM (tmux plugin manager)..."
  
  local tpm_dir="$HOME/.config/tmux/plugins"
  mkdir -p "$tpm_dir"
  
  if [[ ! -d "$tpm_dir/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm.git "$tpm_dir/tpm"
    info "✓ TPM installed"
    warn "Press prefix+I in tmux to install plugins"
  else
    info "TPM already installed"
  fi
}

# Clone or update repository
sync_repo() {
  if [[ -d "$DOTFILES_DIR" ]]; then
    info "Updating existing dotfiles..."
    cd "$DOTFILES_DIR"
    git fetch origin "$BRANCH"
    git reset --hard "origin/$BRANCH"
  else
    info "Cloning dotfiles..."
    git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
  fi
}

# Create local override files if they don't exist
create_local_overrides() {
  info "Creating local override files..."

  # zsh
  if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cat >"$HOME/.zshrc.local" <<'EOF'
# Local zsh configuration (not managed by dotfiles)
# Add your machine-specific settings here

# Add ~/.local/bin to PATH (for tmux-sessionizer and other scripts)
export PATH="$HOME/.local/bin:$PATH"
EOF
    info "Created ~/.zshrc.local"
  fi

  # fish
  mkdir -p "$HOME/.config/fish"
  if [[ ! -f "$HOME/.config/fish/config.local.fish" ]]; then
    cat >"$HOME/.config/fish/config.local.fish" <<'EOF'
# Local fish configuration (not managed by dotfiles)
# Add your machine-specific settings here
EOF
    info "Created ~/.config/fish/config.local.fish"
  fi

  # git
  if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    cat >"$HOME/.gitconfig.local" <<'EOF'
# Local git configuration (not managed by dotfiles)
# Add your machine-specific settings here
# Example:
# [user]
#   name = Your Name
#   email = your@email.com
EOF
    info "Created ~/.gitconfig.local"
  fi
}

# Backup conflicting files
backup_conflicts() {
  local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  local has_conflicts=false

  # Check for conflicts (files that exist and aren't symlinks to our dotfiles)
  while IFS= read -r -d '' file; do
    # Skip meta files
    case "$file" in
      ./.git | ./.git/* | ./.gitignore | ./README.md | ./bootstrap.sh | ./PORTABLE_*)
        continue
        ;;
    esac

    local target="$HOME/${file#./}"
    if [[ -e "$target" && ! -L "$target" ]]; then
      has_conflicts=true
      mkdir -p "$backup_dir/$(dirname "${file#./}")"
      mv "$target" "$backup_dir/${file#./}"
      warn "Backed up: $target -> $backup_dir/${file#./}"
    fi
  done < <(find . -type f -print0)

  if $has_conflicts; then
    info "Existing files backed up to: $backup_dir"
  fi
}

# Apply dotfiles with stow
apply_dotfiles() {
  info "Applying dotfiles with stow..."
  cd "$DOTFILES_DIR"
  backup_conflicts
  stow --restow --target="$HOME" \
    --ignore='^README\.md$' \
    --ignore='^bootstrap\.sh$' \
    --ignore='^PORTABLE_.*' \
    .
}

main() {
  info "Portable Dotfiles Bootstrap"
  echo ""
 
  check_prerequisites
  sync_repo
  install_zsh_plugins
  install_tpm
  create_local_overrides
  apply_dotfiles
 
  echo ""
  info "Done! Dotfiles applied successfully."
  echo ""
  warn "Restart your shell or run: source ~/.zshrc"
  echo ""
  echo "Next steps:"
  echo "  1. Install required tools (see README.md)"
  echo "  2. Press prefix+I in tmux to install plugins"
  echo ""
  echo "Local overrides (your customizations go here):"
  echo "  ~/.zshrc.local"
  echo "  ~/.config/fish/config.local.fish"
  echo "  ~/.gitconfig.local"
}

main "$@"
