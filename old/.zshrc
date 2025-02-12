# fnm
FNM_PATH="/Users/felix.berger/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/felix.berger/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi

eval "$(fnm env --use-on-cd --shell zsh)"
# rbenv
eval "$(rbenv init -)"

# fzf git
source ~/fzf-git.sh/fzf-git.sh

# direnv
eval "$(direnv hook zsh)"

# libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Spring fix?
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
# Postgres fix?
export PGGSSENCMODE="disable"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/felix.berger/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/felix.berger/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/felix.berger/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/felix.berger/google-cloud-sdk/completion.zsh.inc'; fi
