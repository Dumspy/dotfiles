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

## What's Included

- **Shell**: zsh with autosuggestions and completions
- **Terminal**: tmux with TPM plugins (catppuccin, sensible, vim-tmux-navigator)
- **Editor**: Neovim configuration
- **Prompt**: Starship with nerd font symbols
- **Tools**: fzf, lazygit, tmux-sessionizer
- **Automation**: Bootstrap script handles plugin installation

## Prerequisites

### Required

- **git** - for cloning/updating
- **stow** - for symlinking dotfiles

```bash
# macOS
brew install git stow

# Ubuntu/Debian
sudo apt install git stow

# Fedora
sudo dnf install git stow

# Arch
sudo pacman -S git stow
```

### Recommended Tools (Install Separately)

| Tool | macOS | Ubuntu/Debian | Purpose |
|------|--------|---------------|---------|
| **zsh** | `brew install zsh` | `sudo apt install zsh` | Shell (usually pre-installed) |
| **tmux** | `brew install tmux` | `sudo apt install tmux` | Terminal multiplexer |
| **nvim** | `brew install nvim` | `sudo apt install neovim` | Neovim editor |
| **starship** | `brew install starship` | `curl -sS https://starship.rs/install.sh \| sh` | Prompt |
| **fzf** | `brew install fzf` | `sudo apt install fzf` | Fuzzy finder |
| **lazygit** | `brew install lazygit` | See [github.com/jesseduffield/lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |

## Setup Steps

### 1. Install Prerequisites

Follow the tables above to install required and recommended tools.

### 2. Run Bootstrap

The bootstrap script automatically installs:
- **zsh plugins** (zsh-autosuggestions via GitHub clone)
- **TPM** (tmux plugin manager via GitHub clone)

```bash
cd ~/.dotfiles
./bootstrap.sh
```

### 3. Install tmux Plugins

After starting tmux, press:
- `prefix` (default: `Ctrl+Space`) + `I` (capital i)

This installs all TPM plugins defined in `~/.config/tmux/tmux.conf`.

### 4. Restart Shell

```bash
exec zsh  # or your default shell
```

## Plugin Management

### tmux Plugins (TPM)

- **Plugin Manager**: TPM (Tmux Plugin Manager)
- **Installation**: Auto-installed by bootstrap script
- **Plugin Loading**: Press `prefix + I` in tmux
- **Updating Plugins**: Press `prefix + U` in tmux
- **Plugin Config**: Located in `~/.config/tmux/tmux.conf`

Current plugins:
- `tmux-plugins/tpm` - Plugin manager
- `tmux-plugins/tmux-sensible` - Sensible defaults
- `christoomey/vim-tmux-navigator` - Vim/tmux navigation
- `catppuccin/tmux` - Catppuccin theme (macchiato)

### zsh Plugins

- **Location**: `~/.local/share/zsh/plugins/`
- **Installation**: Auto-installed by bootstrap script
- **Updating**: Run bootstrap script again or manual `git pull` in plugin directories
- **Enabling**: Uncomment plugin loading lines in `~/.zshrc`

Current plugins:
- `zsh-autosuggestions` - Fish-like autosuggestions (enabled by default)
- `fzf-tab` - Fuzzy completion (optional, uncomment to enable)

## tmux Usage

- **Prefix key**: `Ctrl+Space` (instead of default `Ctrl+b`)
- **Reload config**: `prefix + r`
- **Install plugins**: `prefix + I`
- **Update plugins**: `prefix + U`
- **Sessionizer**: `prefix + f` (quick project switching)

## Updating

```bash
cd ~/.dotfiles
git pull
./bootstrap.sh
```

Or re-run the one-liner install script.

## Local Customizations

Add machine-specific settings to these files (they won't be overwritten):

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Local zsh configuration |
| `~/.config/fish/config.local.fish` | Local fish configuration |
| `~/.gitconfig.local` | Local git configuration |

These files are automatically sourced by the managed dotfiles.

## Configuration Details

### Platform Support

- **Target platform**: macOS (Darwin)
- **CI runs on**: Linux (Ubuntu) - produces text configs that work on macOS
- **Path handling**: Uses `$HOME` for maximum portability

### Plugin Management

- **Portable mode**: Uses TPM for tmux, manual GitHub clones for zsh plugins
- **Nix mode**: Uses Home Manager for all plugins (not applicable to this branch)

### Hybrid Config Approach

Configs include helpful comments explaining both portable and Nix approaches:
- TPM plugin declarations (portable)
- Nix plugin references (in comments for reference)

This makes the configuration understandable regardless of your background.

## Troubleshooting

### tmux plugins not loading?

1. Ensure TPM is installed: `ls ~/.config/tmux/plugins/tpm`
2. Run plugin install: Press `prefix + I` in tmux
3. Check tmux config: `cat ~/.config/tmux/tmux.conf`

### zsh autosuggestions not working?

1. Check plugin directory: `ls ~/.local/share/zsh/plugins/`
2. Restart shell: `exec zsh`
3. Check `.zshrc` sources plugin: `grep zsh-autosuggestions ~/.zshrc`

### Changes not applying?

1. Re-stow dotfiles: `cd ~/.dotfiles && stow --restow .`
2. Restart shell: `exec $SHELL`
3. Check symlinks: `ls -la ~/.config/tmux/tmux.conf`

### TPM shows errors?

1. Update TPM: `cd ~/.config/tmux/plugins/tpm && git pull`
2. Clean TPM state: `rm -rf ~/.tmux/plugins/*`
3. Press `prefix + I` to reinstall

### fzf not working?

1. Install fzf: `brew install fzf`
2. Run fzf installer: `$(brew --prefix)/opt/fzf/install`
3. Check `.zshrc` sources fzf: `grep "fzf --zsh" ~/.zshrc`

### Starship prompt not showing?

1. Install starship: `curl -sS https://starship.rs/install.sh | sh`
2. Check `.zshrc` sources starship: `grep starship ~/.zshrc`
3. Restart shell: `exec zsh`

## Metadata

- `PORTABLE_SOURCE_SHA` - Git commit from main that generated this
- `PORTABLE_GENERATED_AT` - Timestamp of generation

## Source

Generated from: https://github.com/Dumspy/dotfiles
Nix flake: `.#homeConfigurations.portable`
