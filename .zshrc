typeset -U path cdpath fpath manpath

# HELPDIR removed - install zsh system package

autoload -U compinit && compinit
# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

if [[ $options[zle] = on ]]; then
  source <(fzf --zsh)
fi

# Catppuccin syntax highlighting: install manually if desired

# Set shell options
set_opts=(
  HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
  NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
  NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
)
for opt in "${set_opts[@]}"; do
  setopt "$opt"
done
unset opt set_opts

# ============================================= #
# Zsh Plugins (Portable Mode)                 #
# --------------------------------------------- #
# Bootstrap script installs these via GitHub clone:
# - zsh-autosuggestions
# - fzf-tab (optional - uncomment to enable)
# Nix equivalents: programs.zsh.plugins, programs.zsh.autosuggestion
# ============================================= #

# zsh-autosuggestions (installed by bootstrap)
ZSH_AUTOSUGGESTIONS_DIR="$HOME/.local/share/zsh/plugins/zsh-autosuggestions"
if [[ -f "$ZSH_AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh"
fi

# fzf-tab (optional - not installed by default)
# Uncomment following lines to enable:
# FZF_TAB_DIR="$HOME/.local/share/zsh/plugins/fzf-tab"
# if [[ -f "$FZF_TAB_DIR/fzf-tab.zsh" ]]; then
#   source "$FZF_TAB_DIR/fzf-tab.zsh"
# fi

# Common settings
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
bindkey -s ^f "tmux-sessionizer\n"

# Source local overrides (not managed by dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

if [[ $TERM != "dumb" ]]; then
  eval "$(starship init zsh)"
fi

lg() {
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
    command lazygit "$@"
    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
      cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
      rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}
