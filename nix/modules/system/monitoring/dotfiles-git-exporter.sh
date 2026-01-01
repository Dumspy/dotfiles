#!/usr/bin/env bash

set -euo pipefail

HOSTNAME=$(hostname)
DOTFILES_PATH="@__DOTFILES_PATH__@"

if [ -d "$DOTFILES_PATH/.git" ]; then
  cd "$DOTFILES_PATH"
  
  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  
  # Check if repo is dirty
  if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
    GIT_DIRTY=0
  else
    GIT_DIRTY=1
  fi
  
  # Fetch and check commits behind
  git fetch origin 2>/dev/null || true
  COMMITS_BEHIND=$(git rev-list --count HEAD..origin/$GIT_BRANCH 2>/dev/null || echo 0)
else
  GIT_BRANCH="unknown"
  GIT_COMMIT="unknown"
  GIT_DIRTY=0
  COMMITS_BEHIND=0
fi

# Output Prometheus metrics
cat <<EOF
# HELP dotfiles_git_info Dotfiles Git branch and commit info
# TYPE dotfiles_git_info gauge
dotfiles_git_info{hostname="$HOSTNAME",branch="$GIT_BRANCH",commit="$GIT_COMMIT"} 1

# HELP dotfiles_git_commits_behind Number of commits behind remote
# TYPE dotfiles_git_commits_behind gauge
dotfiles_git_commits_behind{hostname="$HOSTNAME",remote="origin",branch="$GIT_BRANCH"} $COMMITS_BEHIND

# HELP dotfiles_git_dirty Whether dotfiles repo has uncommitted changes
# TYPE dotfiles_git_dirty gauge
dotfiles_git_dirty{hostname="$HOSTNAME"} $GIT_DIRTY
EOF
