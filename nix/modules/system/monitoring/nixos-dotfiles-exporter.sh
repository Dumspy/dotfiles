#!/usr/bin/env bash

set -euo pipefail

# Get hostname
HOSTNAME=$(hostname)

# Get NixOS generation from profile link
CURRENT_GEN=$(readlink /nix/var/nix/profiles/system | sed 's/.*-\([0-9]*\)-link/\1/' || echo "0")

# Get last rebuild timestamp
REBUILD_TIME=$(stat -c '%Y' /run/current-system)

# Get dotfiles Git metrics
DOTFILES_PATH="@__DOTFILES_PATH__@"

echo "DEBUG: DOTFILES_PATH=$DOTFILES_PATH" >&2
echo "DEBUG: Checking if directory exists..." >&2
ls -la "$DOTFILES_PATH" >&2 || echo "DEBUG: Directory doesn't exist" >&2

if [ -d "$DOTFILES_PATH/.git" ]; then
  echo "DEBUG: .git directory found" >&2
  cd "$DOTFILES_PATH"

  # Configure git to trust this directory when running as root
  # git config --global --add safe.directory "$DOTFILES_PATH" 2>&1 >&2 || true

  echo "DEBUG: Running git commands..." >&2
  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>&1 | tee /dev/stderr || echo "unknown")
  GIT_COMMIT=$(git rev-parse --short HEAD 2>&1 | tee /dev/stderr || echo "unknown")

  echo "DEBUG: GIT_BRANCH=$GIT_BRANCH" >&2
  echo "DEBUG: GIT_COMMIT=$GIT_COMMIT" >&2

  # Check if repo is dirty
  if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
    GIT_DIRTY=0
  else
    GIT_DIRTY=1
  fi

  # Check commits behind (requires network, may fail)
  COMMITS_BEHIND=$(git fetch origin 2>/dev/null && git rev-list --count HEAD..origin/$GIT_BRANCH 2>/dev/null || echo 0)
else
  echo "DEBUG: .git directory NOT found" >&2
  GIT_BRANCH="unknown"
  GIT_COMMIT="unknown"
  GIT_DIRTY=0
  COMMITS_BEHIND=0
fi

# Output Prometheus metrics
cat <<EOF
# HELP nixos_generation_current Current NixOS system generation
# TYPE nixos_generation_current gauge
nixos_generation_current{hostname="$HOSTNAME"} $CURRENT_GEN

# HELP nixos_last_rebuild_timestamp Last system rebuild Unix timestamp
# TYPE nixos_last_rebuild_timestamp gauge
nixos_last_rebuild_timestamp{hostname="$HOSTNAME"} $REBUILD_TIME

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
