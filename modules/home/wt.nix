{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.wt;
  wtWorktreeDir = cfg.worktreeDir or "~/.wt-worktrees";
in {
  options.myModules.home.wt = {
    enable = lib.mkEnableOption "git worktree management (fish functions)";

    worktreeDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.wt-worktrees";
      description = "Root directory where per-repo worktrees are stored.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      interactiveShellInit = lib.mkAfter ''
        set -gx WT_WORKTREE_DIR ${wtWorktreeDir}
      '';

      functions = {
        __wt_main_root = ''
          set -l worktrees (command git worktree list --porcelain 2>/dev/null | string match -r '^worktree .+')
          if test (count $worktrees) -eq 0
            return 1
          end
          string replace -r '^worktree ' "" -- $worktrees[1]
        '';

        __wt_repo_dir = ''
          set -l main_root (__wt_main_root)
          if test -z "$main_root"
            return 1
          end
          printf "%s/%s\n" $WT_WORKTREE_DIR (basename "$main_root")
        '';

        __wt_default_base = ''
          set -l default (command git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | string replace -r '^origin/' ${"''"})
          if test -n "$default"
            printf "%s\n" "$default"
            return 0
          end
          if command git show-ref --verify --quiet refs/heads/master
            printf "master\n"
          else if command git show-ref --verify --quiet refs/heads/main
            printf "main\n"
          end
        '';

        __wt_normalize_path = ''
          if test -z "$argv[1]"
            return 1
          end
          if test -d "$argv[1]"
            command sh -c 'cd "$1" && pwd -P' sh "$argv[1]"
          else
            printf "%s\n" "$argv[1]"
          end
        '';

        __wt_is_registered = ''
          set -l target (__wt_normalize_path "$argv[1]")
          if test -z "$target"
            set target "$argv[1]"
          end
          set -l worktrees (command git worktree list --porcelain 2>/dev/null | string match -r '^worktree .+')
          contains -- "worktree $target" $worktrees
        '';

        __wt_session_name = ''
          set -l repo_dir $argv[1]
          set -l target $argv[2]

          if test -z "$repo_dir" -o -z "$target"
            return 1
          end

          set -l repo_prefix "$repo_dir/"
          if string match -q -- "$repo_prefix*" "$target"
            set -l repo_name (basename "$repo_dir" | string replace -a '.' '_' | string replace -a ' ' '_')
            set -l worktree_name (basename "$target" | string replace -a '.' '_' | string replace -a ' ' '_')
            printf "%s/%s\n" $repo_name $worktree_name
          else
            basename "$target" | string replace -a '.' '_' | string replace -a ' ' '_'
          end
        '';

        __wt_rename_tmux_window = ''
          if not set -q TMUX
            return 0
          end
          if not command -sq tmux
            return 0
          end
          command tmux rename-window -- $argv[1] >/dev/null 2>/dev/null
        '';

        __wt_focus_tmux_session = ''
          set -l name $argv[1]
          set -l target $argv[2]

          if not command -sq tmux
            return 1
          end

          if set -q TMUX
            if command tmux has-session -t="$name" >/dev/null 2>&1
              command tmux switch-client -t "$name"
            else
              command tmux new-session -ds "$name" -c "$target" >/dev/null
              command tmux switch-client -t "$name"
            end
          else
            if command tmux has-session -t="$name" >/dev/null 2>&1
              command tmux attach-session -t "$name"
            else
              command tmux new-session -s "$name" -c "$target"
            end
          end
        '';

        wt = ''
          if not command git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "wt: not in a git repo" >&2
            return 1
          end

          set -l branch "$argv[1]"
          if test -z "$branch"
            echo "Usage: wt branch [base]" >&2
            return 1
          end

          set -l base "$argv[2]"
          if test -z "$base"
            set base (__wt_default_base)
          end

          set -l repo_dir (__wt_repo_dir)
          if test -z "$repo_dir"
            return 1
          end
          command mkdir -p -- "$repo_dir"

          set -l target "$repo_dir/$branch"

          if test -d "$target"
            if __wt_is_registered "$target"
              cd "$target"
              return 0
            end
            echo "wt: $target exists but is not a git worktree" >&2
            return 1
          end

          if command git show-ref --verify --quiet "refs/heads/$branch"
            command git worktree add "$target" "$branch" >/dev/null
          else
            command git worktree add -b "$branch" "$target" "$base" >/dev/null
          end

          if test $status -ne 0
            return 1
          end

          cd "$target"
        '';

        wtcd = ''
          if test -z "$argv[1]"
            echo "Usage: wtcd <directory>" >&2
            return 1
          end

          set -l repo_dir (__wt_repo_dir)
          if test -z "$repo_dir"
            return 1
          end

          cd "$repo_dir/$argv[1]"
        '';

        wtl = ''
          command git worktree list
        '';

        wtp = ''
          command git worktree prune -v
        '';

        wtrm = ''
          set -l main_root (__wt_main_root)
          if test -z "$main_root"
            return 1
          end

          set -l current_root (command git rev-parse --show-toplevel 2>/dev/null)
          if test -n "$current_root"
            set current_root (__wt_normalize_path "$current_root")
          end

          set -l name_arg
          set -l extra_args
          for arg in $argv
            if string match -q -- '-*' "$arg"
              set extra_args $extra_args $arg
            else if test -z "$name_arg"
              set name_arg "$arg"
            else
              echo "wtrm: unexpected extra positional argument: $arg" >&2
              return 1
            end
          end

          set -l target
          if test -n "$name_arg"
            if string match -q -- '/*' "$name_arg"
              set target "$name_arg"
            else
              set -l repo_dir (__wt_repo_dir)
              if test -z "$repo_dir"
                return 1
              end
              set target "$repo_dir/$name_arg"
            end
          else
            if test "$current_root" = "$main_root"
              echo "wtrm: give a name or run inside a worktree" >&2
              return 1
            end
            set target "$current_root"
          end

          set -l normalized_target (__wt_normalize_path "$target")
          if test -n "$normalized_target"
            set target "$normalized_target"
          end

          if test "$target" = "$main_root"
            echo "wtrm: refusing to remove main worktree" >&2
            return 1
          end

          if not __wt_is_registered "$target"
            echo "wtrm: no worktree at $target" >&2
            return 1
          end

          set -l inside 0
          if test "$current_root" = "$target"
            set inside 1
          end

          if test $inside -eq 1
            cd "$main_root"
            or return 1
          end

          command git -C "$main_root" worktree remove $extra_args "$target"
          set -l remove_status $status

          if test $remove_status -eq 0
            if test $inside -eq 1
              __wt_rename_tmux_window (basename "$main_root")
            end
          end

          return $remove_status
        '';

        wtmux = ''
          set -l branch "$argv[1]"
          set -l target

          if test -n "$branch"
            set -l repo_dir (__wt_repo_dir)
            if test -z "$repo_dir"
              return 1
            end
            set target "$repo_dir/$branch"
          else
            set -l current_root (command git rev-parse --show-toplevel 2>/dev/null)
            if test -z "$current_root"
              echo "wtmux: not in a git repo" >&2
              return 1
            end
            set target (__wt_normalize_path "$current_root")
          end

          if not __wt_is_registered "$target"
            echo "wtmux: not a registered worktree: $target" >&2
            return 1
          end

          set -l repo_dir (__wt_repo_dir)
          if test -z "$repo_dir"
            return 1
          end
          set -l session_name (__wt_session_name "$repo_dir" "$target")
          if test -z "$session_name"
            return 1
          end

          __wt_focus_tmux_session "$session_name" "$target"
        '';

        wth = ''
          set -l branch "$argv[1]"
          set -l target

          if test -n "$branch"
            set -l repo_dir (__wt_repo_dir)
            if test -z "$repo_dir"
              return 1
            end
            set target "$repo_dir/$branch"
          else
            set -l current_root (command git rev-parse --show-toplevel 2>/dev/null)
            if test -z "$current_root"
              echo "wth: not in a git repo" >&2
              return 1
            end
            set target (__wt_normalize_path "$current_root")
          end

          set -l main_root (__wt_main_root)
          if test -z "$main_root"
            return 1
          end

          if test -n "$branch"
            if not test -d "$target"
              wt "$branch"
              or return 1
            end
          end

          if not __wt_is_registered "$target"
            echo "wth: not a registered worktree: $target" >&2
            return 1
          end

          command herdr worktree open --cwd "$main_root" --path "$target" --focus
        '';
      };
    };
  };
}
