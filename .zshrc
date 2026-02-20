typeset -U path cdpath fpath manpath

# HELPDIR removed - install zsh system package

autoload -U compinit && compinit
# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

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
# Portable modules loader                       #
# --------------------------------------------- #
# In portable mode, module-specific zsh setup is
# split into files under ~/.config/zsh/modules.
# This keeps ~/.zshrc focused on bootstrapping.
# ============================================= #

if [[ -d "$HOME/.config/zsh/modules" ]]; then
  for module in "$HOME"/.config/zsh/modules/*.zsh(N); do
    source "$module"
  done
fi

# Source local overrides (not managed by dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

function lg() {
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
    command lazygit "$@"
    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
      cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
      rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}
