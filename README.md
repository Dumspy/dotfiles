# Portable Dotfiles

This branch contains automatically generated, stow-ready dotfiles exported from a Nix-based configuration.

**⚠️ Do not edit files in this branch directly.** Changes are overwritten on each generation.

## Quick Start

### One-liner Install

```bash
curl -fsSL https://raw.githubusercontent.com/Dumspy/dotfiles/portable/bootstrap.sh | bash
```

### Manual Install

```bash
# Clone the portable branch
git clone --branch portable --single-branch https://github.com/Dumspy/dotfiles.git ~/.dotfiles

# Apply with stow
cd ~/.dotfiles
stow --target="$HOME" .

# Restart your shell
exec $SHELL
```

## Prerequisites

- **git** - for cloning/updating
- **stow** - for symlinking dotfiles

Install stow:
```bash
# Ubuntu/Debian
sudo apt install stow

# macOS
brew install stow

# Fedora
sudo dnf install stow

# Arch
sudo pacman -S stow
```

## Updating

```bash
cd ~/.dotfiles
git pull
stow --restow --target="$HOME" .
```

Or re-run the bootstrap script:
```bash
~/.dotfiles/bootstrap.sh
```

## Local Customizations

Add machine-specific settings to these files (they won't be overwritten):

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Local zsh configuration |
| `~/.config/fish/config.local.fish` | Local fish configuration |
| `~/.gitconfig.local` | Local git configuration |

These files are automatically sourced by the managed dotfiles.

## Metadata

- `PORTABLE_SOURCE_SHA` - Git commit from main that generated this
- `PORTABLE_GENERATED_AT` - Timestamp of generation

## Source

Generated from: https://github.com/Dumspy/dotfiles
