# starship
eval "$(starship init zsh)"

# fnm
FNM_PATH="/Users/felix.berger/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/felix.berger/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi

eval "$(fnm env --use-on-cd --shell zsh)"
# rbenv
eval "$(rbenv init -)"

# 1password
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# fzf git
source ~/fzf-git.sh/fzf-git.sh

# zsh_profile
source ~/.zsh_profile
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

# Disable postinstalls for yarn/npm
export YARN_ENABLE_SCRIPTS=false
export npm_config_ignore_scripts=true

# opencode
export PATH=/Users/felix.berger/.opencode/bin:$PATH
