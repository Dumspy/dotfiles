# Git Worktree Workflow

This document explains the bare repository + worktree workflow used in this dotfiles configuration.

## Overview

Instead of cloning repositories normally, we use a **bare clone** with **git worktrees**. This allows you to have multiple branches checked out simultaneously as separate directories, all sharing the same git history.

```
myproject/
├── .bare/           # bare repository (shared git data)
├── .git             # file pointing to .bare/
├── main/            # main branch worktree
├── feature-auth/    # feature branch worktree
└── hotfix-123/      # hotfix branch worktree
```

### Benefits

- **Multiple branches open simultaneously** - no stashing or committing WIP
- **Faster branch switching** - just `cd` to another directory
- **Isolated working directories** - each worktree has its own node_modules, build cache, etc.
- **Shared git history** - all worktrees share the same `.bare/` repository

## Getting Started

### Cloning a New Repository

Use `git-clone-bare` instead of `git clone`:

```bash
# Using GitHub shorthand (requires gh CLI)
git-clone-bare owner/repo

# Clone your own repo
git-clone-bare myrepo

# Using full URL
git-clone-bare https://github.com/owner/repo
```

This creates:
```
repo/
├── .bare/      # bare repository
├── .git        # pointer to .bare/
└── main/       # default branch worktree
```

### tmux Integration

The workflow is integrated with tmux:

| Keybind | Action |
|---------|--------|
| `prefix + f` | **Session picker** - find and switch to repositories |
| `prefix + w` | **Worktree picker** - switch between worktrees (opens as window) |
| `prefix + W` | **New worktree** - create a new worktree from branch |

#### Session = Repository

Each repository gets **one tmux session**. Use `prefix + f` to:
- Find repositories in your search paths
- Switch between repository sessions
- See existing tmux sessions

#### Window = Worktree

Each worktree opens as a **tmux window** within the session. Use `prefix + w` to:
- List all worktrees for the current repository
- See git diff stats (+added/-deleted lines)
- Switch to existing worktree window or create new one

## Daily Workflow

### 1. Open a Project

```bash
# In tmux, press: prefix + f
# Select your repository from the list
```

### 2. Work on a Feature

```bash
# Press: prefix + W
# Type or select branch name: feature/new-auth
# A new worktree is created and opened as a window
```

### 3. Switch Between Worktrees

```bash
# Press: prefix + w
# Select the worktree you want to switch to
# Shows: worktree-name (branch) +5 -3
```

### 4. Clean Up When Done

```bash
# From project root (not inside a worktree)
cd ~/repos/myproject
git worktree remove feature-auth

# Or from any worktree in the project
git worktree list                    # see all worktrees
git worktree remove ../feature-auth  # remove by path
```

## Commands Reference

### git-clone-bare

Clone a repository using the bare worktree pattern.

```bash
git-clone-bare <repo> [directory]

# Examples:
git-clone-bare owner/repo              # GitHub shorthand
git-clone-bare myrepo                  # Your own repo  
git-clone-bare https://github.com/x/y  # Full URL
git-clone-bare git@github.com:x/y.git  # SSH URL
```

### tmux-worktree

Manage worktrees within tmux.

```bash
tmux-worktree           # Pick existing worktree (fzf)
tmux-worktree --new     # Create new worktree (fzf branch picker)
tmux-worktree --help    # Show help
```

### tmux-sessionizer

Find and switch to repository sessions.

```bash
tmux-sessionizer        # Pick repository/session (fzf)
tmux-sessionizer <path> # Open specific path as session
```

### tmux-git-status

Display worktree info for tmux status bar.

```bash
tmux-git-status [path]  # Returns: worktree-name +add -del
```

## Git Worktree Commands

Standard git worktree commands work as expected:

```bash
# List all worktrees
git worktree list

# Add worktree for existing branch
git worktree add ../feature-x feature-x

# Add worktree with new branch
git worktree add -b feature-y ../feature-y

# Remove worktree
git worktree remove ../feature-x

# Prune stale worktree info
git worktree prune
```

## Directory Structure

Recommended layout:

```
~/repos/
├── project-a/
│   ├── .bare/
│   ├── main/
│   └── feature-x/
├── project-b/
│   ├── .bare/
│   ├── main/
│   └── develop/
└── dotfiles/          # Can be regular repo or bare
```

Configure search paths in your Nix config:

```nix
myModules.home.tmux-sessionizer = {
  enable = true;
  searchPaths = [
    "$HOME/repos:2"      # depth 2
    "$HOME/dotfiles"
  ];
};
```

## Tips

### Naming Worktrees

Worktrees are named after the branch with `/` replaced by `-`:
- `feature/auth` → `feature-auth/`
- `hotfix/123` → `hotfix-123/`

### Shared vs Isolated Files

**Shared** (in `.bare/`):
- Git history, branches, tags
- Remote configuration
- Hooks

**Isolated** (per worktree):
- Working files
- node_modules, vendor, target, etc.
- Build artifacts
- Local IDE settings

### Converting Existing Repos

To convert an existing clone to bare worktree pattern:

```bash
cd ~/repos
mv myproject myproject-old

# Clone fresh with bare pattern
git-clone-bare owner/myproject

# If you have local changes, cherry-pick or copy them
cd myproject/main
git remote add old ../myproject-old
git fetch old
git cherry-pick <commits>

# Clean up
rm -rf ../myproject-old
```

## Troubleshooting

### "Not inside a git repository"

Make sure you're inside a worktree directory, not the project root:
```bash
cd ~/repos/myproject/main  # ✓ inside worktree
cd ~/repos/myproject       # ✗ project root (no working tree)
```

### Worktree not showing in picker

The worktree picker uses `git worktree list`. Verify:
```bash
git worktree list
```

If empty, you might be in a regular (non-bare) repository.

### Session name conflicts

Session names are derived from the repository name. If you have two repos with the same name in different locations, they'll use the same session.
