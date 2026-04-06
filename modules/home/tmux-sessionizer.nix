{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.tmux-sessionizer;
  portable = config.myModules.home.portable or false;

  searchPathsStr = lib.concatStringsSep " " cfg.searchPaths;
  extraPathsStr = lib.concatStringsSep " " (cfg.extraPaths or []);

  tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''

    # ============================================================================
    # Configuration (managed by Nix)
    # ============================================================================

    # Search paths for git repositories with depth control
    # Format: path:depth (depth is optional, defaults to TS_MAX_DEPTH)
    TS_SEARCH_PATHS=(${searchPathsStr})

    # Extra paths that aren't git repos (shown as-is)
    TS_EXTRA_PATHS=(${extraPathsStr})

    # Default max depth for paths without explicit depth
    TS_MAX_DEPTH=2

    # Optional: Session commands for special windows
    # Example: TS_SESSION_COMMANDS=("lazygit" "btop" "npm run dev")
    # Usage: tmux-sessionizer -s 0 (opens first command in window 69)
    # TS_SESSION_COMMANDS=()

    # Logging (disabled by default)
    # TS_LOG=true  # Uncomment to enable logging
    # TS_LOG_FILE="$HOME/.local/share/tmux-sessionizer/tmux-sessionizer.logs"

    # Pane cache directory
    PANE_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/tmux-sessionizer"
    PANE_CACHE_FILE="$PANE_CACHE_DIR/panes.cache"

    # ============================================================================
    # Script Implementation
    # ============================================================================

    log() {
        if [[ -z $TS_LOG ]]; then
            return
        elif [[ $TS_LOG == "echo" ]]; then
            echo "$*"
        elif [[ $TS_LOG == "file" ]]; then
            echo "$*" >> "$TS_LOG_FILE"
        fi
    }

    session_idx=""
    session_cmd=""
    user_selected=""
    split_type=""
    VERSION="0.2.0"

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
        -h | --help)
            echo "Usage: tmux-sessionizer [OPTIONS] [SEARCH_PATH]"
            echo "Options:"
            echo "  -h, --help             Display this help message"
            echo "  -s, --session <idx>   Run session command by index"
            echo "  --vsplit              Create vertical split for session command"
            echo "  --hsplit              Create horizontal split for session command"
            exit 0
            ;;
        -s | --session)
            session_idx="$2"
            if [[ -z $session_idx ]]; then
                echo "Session index cannot be empty"
                exit 1
            fi

            if [[ -z $TS_SESSION_COMMANDS ]]; then
                echo "TS_SESSION_COMMANDS is not set. Must have commands configured."
                exit 1
            fi

            if [[ -z "$session_idx" || "$session_idx" -lt 0 || "$session_idx" -ge "''${#TS_SESSION_COMMANDS[@]}" ]]; then
                echo "Error: Invalid index. Please provide 0 to $((''${#TS_SESSION_COMMANDS[@]} - 1))."
                exit 1
            fi

            session_cmd="''${TS_SESSION_COMMANDS[$session_idx]}"
            shift
            ;;
        --vsplit)
            split_type="vsplit"
            ;;
        --hsplit)
            split_type="hsplit"
            ;;
        -v | --version)
            echo "tmux-sessionizer version $VERSION"
            exit 0
            ;;
        *)
            user_selected="$1"
            ;;
        esac
        shift
    done

    log "tmux-sessionizer($VERSION): idx=$session_idx cmd=$session_cmd user_selected=$user_selected split_type=$split_type"

    if [[ -n "$split_type" && -z "$session_idx" ]]; then
        echo "Error: --vsplit and --hsplit require -s option"
        exit 1
    fi

    sanity_check() {
        if ! command -v tmux &>/dev/null; then
            echo "tmux is not installed."
            exit 1
        fi
        if ! command -v fzf &>/dev/null; then
            echo "fzf is not installed."
            exit 1
        fi
    }

    switch_to() {
        if [[ -z $TMUX ]]; then
            tmux attach-session -t "$1"
        else
            tmux switch-client -t "$1"
        fi
    }

    has_session() {
        tmux list-sessions 2>/dev/null | grep -q "^$1:"
    }

    hydrate() {
        if [[ -n "$session_cmd" ]]; then
            return
        fi
        if [ -f "$2/.tmux-sessionizer" ]; then
            tmux send-keys -t "$1" "source $2/.tmux-sessionizer" C-m
        elif [ -f "$HOME/.tmux-sessionizer" ]; then
            tmux send-keys -t "$1" "source $HOME/.tmux-sessionizer" C-m
        fi
    }

    is_tmux_running() {
        if [[ -z $TMUX ]] && [[ -z $(pgrep tmux) ]]; then
            return 1
        fi
        return 0
    }

    init_pane_cache() {
        mkdir -p "$PANE_CACHE_DIR"
        touch "$PANE_CACHE_FILE"
    }

    get_pane_id() {
        local session_idx="$1"
        local split_type="$2"
        init_pane_cache
        grep "^''${session_idx}:''${split_type}:" "$PANE_CACHE_FILE" | cut -d: -f3
    }

    set_pane_id() {
        local session_idx="$1"
        local split_type="$2"
        local pane_id="$3"
        init_pane_cache
        grep -v "^''${session_idx}:''${split_type}:" "$PANE_CACHE_FILE" > "''${PANE_CACHE_FILE}.tmp" 2>/dev/null || true
        mv "''${PANE_CACHE_FILE}.tmp" "$PANE_CACHE_FILE"
        echo "''${session_idx}:''${split_type}:''${pane_id}" >> "$PANE_CACHE_FILE"
    }

    cleanup_dead_panes() {
        init_pane_cache
        local temp_file="''${PANE_CACHE_FILE}.tmp"
        while IFS=: read -r idx split pane_id; do
            if tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^''${pane_id}$"; then
                echo "''${idx}:''${split}:''${pane_id}" >> "$temp_file"
            fi
        done < "$PANE_CACHE_FILE"
        mv "$temp_file" "$PANE_CACHE_FILE" 2>/dev/null || touch "$PANE_CACHE_FILE"
    }

    sanity_check

    [[ -n "$TS_SEARCH_PATHS" ]] || TS_SEARCH_PATHS=(~/Documents)

    if [[ ''${#TS_EXTRA_PATHS[@]} -gt 0 ]]; then
        TS_SEARCH_PATHS+=("''${TS_EXTRA_PATHS[@]}")
    fi

    # Get all worktrees for a given repo path
    get_worktrees() {
        local repo_path="$1"
        git -C "$repo_path" worktree list --porcelain 2>/dev/null | while read -r line; do
            if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
                local wt_path="''${BASH_REMATCH[1]}"
                # Skip the main repo itself
                if [[ "$wt_path" != "$repo_path" ]]; then
                    local wt_name=$(basename "$wt_path")
                    echo "''${repo_path}/''${wt_name}"
                fi
            fi
        done
    }

    # Find all directories (git repos + worktrees + extra paths)
    find_dirs() {
        # List TMUX sessions first
        if [[ -n "''${TMUX}" ]]; then
            current_session=$(tmux display-message -p '#S')
            tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null | grep -vFx "[TMUX] $current_session"
        else
            tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null
        fi

        # Process each search path
        for entry in "''${TS_SEARCH_PATHS[@]}"; do
            # Parse path:depth format
            if [[ "$entry" =~ ^([^:]+):([0-9]+)$ ]]; then
                path="''${BASH_REMATCH[1]}"
                depth="''${BASH_REMATCH[2]}"
            else
                path="$entry"
                depth="''${TS_MAX_DEPTH:-2}"
            fi

            [[ -d "$path" ]] || continue

            # Check if this is a git repo
            if [[ -d "$path/.git" ]]; then
                # It's a git repo - show it and its worktrees
                echo "$path"
                get_worktrees "$path"
            elif [[ -d "$path/.bare" ]]; then
                # Bare repo - just show it
                echo "$path"
            else
                # Non-git directory - show as-is
                echo "$path"
            fi

            # Search for git repos within this path
            find "$path" -mindepth 1 -maxdepth "''${depth}" -type d 2>/dev/null | while read -r dir; do
                if [[ -d "$dir/.git" ]]; then
                    echo "$dir"
                    get_worktrees "$dir"
                fi
            done
        done
    }

    handle_session_cmd() {
        if ! is_tmux_running; then
            echo "Error: tmux is not running."
            exit 1
        fi

        current_session=$(tmux display-message -p '#S')

        if [[ -n "$split_type" ]]; then
            handle_split_session_cmd "$current_session"
        else
            handle_window_session_cmd "$current_session"
        fi
        exit 0
    }

    handle_window_session_cmd() {
        local current_session="$1"
        start_index=$((69 + $session_idx))
        target="$current_session:$start_index"

        if tmux has-session -t="$target" 2>/dev/null; then
            switch_to "$target"
        else
            tmux neww -dt "$target" "$session_cmd"
            hydrate "$target" "$selected"
            tmux select-window -t "$target"
        fi
    }

    handle_split_session_cmd() {
        local current_session="$1"
        cleanup_dead_panes

        local existing_pane_id=$(get_pane_id "$session_idx" "$split_type")

        if [[ -n "$existing_pane_id" ]] && tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^''${existing_pane_id}$"; then
            tmux select-pane -t "$existing_pane_id"
            if [[ -z $TMUX ]]; then
                tmux attach-session -t "$current_session"
            else
                tmux switch-client -t "$current_session"
            fi
        else
            local split_flag=""
            if [[ "$split_type" == "vsplit" ]]; then
                split_flag="-h"
            else
                split_flag="-v"
            fi

            local new_pane_id=$(tmux split-window $split_flag -c "$(pwd)" -P -F "#{pane_id}" "$session_cmd")

            if [[ -n "$new_pane_id" ]]; then
                set_pane_id "$session_idx" "$split_type" "$new_pane_id"
            fi
        fi
    }

    if [[ -n "$session_cmd" ]]; then
        handle_session_cmd
    elif [[ -n "$user_selected" ]]; then
        selected="$user_selected"
    else
        selected=$(find_dirs | fzf)
    fi

    [[ -z "$selected" ]] && exit 0

    # Handle [TMUX] session selection
    if [[ "$selected" =~ ^\[TMUX\]\ (.+)$ ]]; then
        switch_to "''${BASH_REMATCH[1]}"
        exit 0
    fi

    # Handle worktree selection (parent/worktree format)
    if [[ "$selected" =~ ^(.+)/([^/]+)$ ]]; then
        selected_name="''${BASH_REMATCH[2]}"
    else
        selected_name=$(basename "$selected" | tr '. ' '_')
    fi

    if ! is_tmux_running; then
        tmux new-session -ds "$selected_name" -c "$selected"
        hydrate "$selected_name" "$selected"
    elif ! has_session "$selected_name"; then
        tmux new-session -ds "$selected_name" -c "$selected"
        hydrate "$selected_name" "$selected"
    fi

    switch_to "$selected_name"
  '';
in {
  options.myModules.home.tmux-sessionizer = {
    enable = lib.mkEnableOption "tmux-sessionizer for quick project switching";

    searchPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["$HOME/Documents:3"];
      description = "List of paths to search for git repositories. Format: path:depth";
    };

    extraPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra non-git directories to show in sessionizer";
    };

    wtWorktreeDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.wt-worktrees";
      description = "Directory where wt stores worktrees";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (!portable) [tmux-sessionizer];

    home.file.".local/bin/tmux-sessionizer" = lib.mkIf portable {
      executable = true;
      text = builtins.readFile "${tmux-sessionizer}/bin/tmux-sessionizer";
    };
  };
}
