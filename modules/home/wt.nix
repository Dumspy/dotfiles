{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.wt;
  portable = config.myModules.home.portable or false;
  wtWorktreeDir = cfg.worktreeDir or "~/.wt-worktrees";
in {
  options.myModules.home.wt = {
    enable = lib.mkEnableOption "git worktree management (wt function)";

    worktreeDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.wt-worktrees";
      description = "Directory where worktrees are stored";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      interactiveShellInit = lib.mkAfter ''
        # ============================================================================
        # wt - worktree management
        # ============================================================================

        function __wt_main_root
          set -l worktrees (command git worktree list --porcelain 2>/dev/null | string match -r '^worktree .+')
          if test (count $worktrees) -eq 0
            return 1
          end
          string replace -r '^worktree ' "" -- $worktrees[1]
        end

        function __wt_repo_dir
          set -l main_root (__wt_main_root)
          if test -z "$main_root"
            return 1
          end
          printf "%s/%s\n" ${wtWorktreeDir} (basename "$main_root")
        end

        function __wt_normalize_path
          if test -z "$argv[1]"
            return 1
          end
          if test -d "$argv[1]"
            command sh -c 'cd "$1" && pwd -P' sh "$argv[1]"
          else
            printf "%s\n" "$argv[1]"
          end
        end

        function __wt_random_name
          set -l left amber ash brisk cedar cinder comet copper ember flint frost harbor ivory juniper maple mist north orbit raven river scout silver solar stone swift timber topo
          set -l right ant bird bloom brook cloud cove dune field finch flame fox grove hawk leaf meadow moth owl pine reef ridge sparrow star surf trout wave wolf wren
          printf "%s-%s\n" $left[(random 1 (count $left))] $right[(random 1 (count $right))]
        end

        function __wt_pick_name
          set -l repo_dir (__wt_repo_dir)
          if test -z "$repo_dir"
            return 1
          end

          set -l attempts 0
          while test $attempts -lt 40
            set attempts (math "$attempts + 1")
            set -l candidate (__wt_random_name)

            if test -e "$repo_dir/$candidate"
              continue
            end
            if command git show-ref --verify --quiet "refs/heads/$candidate"
              continue
            end

            printf "%s\n" "$candidate"
            return 0
          end

          while true
            set -l candidate (__wt_random_name)-(random 100 999)
            if test -e "$repo_dir/$candidate"
              continue
            end
            if command git show-ref --verify --quiet "refs/heads/$candidate"
              continue
            end
            printf "%s\n" "$candidate"
            return 0
          end
        end

        function __wt_is_registered
          set -l target (__wt_normalize_path "$argv[1]")
          if test -z "$target"
            set target "$argv[1]"
          end
          set -l worktrees (command git worktree list --porcelain 2>/dev/null | string match -r '^worktree .+')
          contains -- "worktree $target" $worktrees
        end

        function __wt_rename_tmux_window
          if not set -q TMUX
            return 0
          end
          if not command -sq tmux
            return 0
          end
          command tmux rename-window -- $argv[1] >/dev/null 2>/dev/null
        end

        function __wt_session_name
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
        end

        function __wt_focus_tmux_session
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
        end

        function __wt_open
          set -l name $argv[1]
          if test -z "$name"
            echo "wt: missing name" >&2
            return 1
          end

          set -l repo_dir (__wt_repo_dir)
          if test -z "$repo_dir"
            return 1
          end

          set -l target "$repo_dir/$name"
          set -l session_name (__wt_session_name "$repo_dir" "$target")
          command mkdir -p -- "$repo_dir"

          if test -d "$target"
            if __wt_is_registered "$target"
              if __wt_focus_tmux_session "$session_name" "$target"
                return 0
              end

              cd "$target"
              or return 1
              return 0
            end
            echo "wt: $target exists but is not a git worktree" >&2
            return 1
          end

          if command git show-ref --verify --quiet "refs/heads/$name"
            command git worktree add "$target" "$name" >/dev/null
          else
            command git worktree add -b "$name" "$target" HEAD >/dev/null
          end
          if test $status -ne 0
            return 1
          end

          if __wt_focus_tmux_session "$session_name" "$target"
            return 0
          end

          cd "$target"
          or return 1
        end

        function __wt_remove
          set -l main_root (__wt_main_root)
          if test -z "$main_root"
            return 1
          end

          set -l current_root (command git rev-parse --show-toplevel 2>/dev/null)
          if test -n "$current_root"
            set current_root (__wt_normalize_path "$current_root")
          end

          set -l target
          if test -n "$argv[1]"
            if string match -q -- '/*' "$argv[1]"
              set target "$argv[1]"
            else
              set -l repo_dir (__wt_repo_dir)
              if test -z "$repo_dir"
                return 1
              end
              set target "$repo_dir/$argv[1]"
            end
          else
            if test "$current_root" = "$main_root"
              echo "wt: give a name or run inside a worktree" >&2
              return 1
            end
            set target "$current_root"
          end

          set -l normalized_target (__wt_normalize_path "$target")
          if test -n "$normalized_target"
            set target "$normalized_target"
          end

          if test "$target" = "$main_root"
            echo "wt: refusing to remove main worktree" >&2
            return 1
          end

          if not __wt_is_registered "$target"
            echo "wt: no worktree at $target" >&2
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

          command git -C "$main_root" worktree remove "$target"

          if test $inside -eq 1
            __wt_rename_tmux_window (basename "$main_root")
          end
        end

        function wt
          if not command git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "wt: not in a git repo" >&2
            return 1
          end

          set -l subcommand "$argv[1]"

          switch "$subcommand"
            case ""
              set -l name (__wt_pick_name)
              if test -z "$name"
                return 1
              end
              __wt_open "$name"
            case ls list
              command git worktree list
            case rm remove
              __wt_remove $argv[2]
            case -h --help help
              echo "usage: wt [name]"
              echo "       wt ls"
              echo "       wt rm [name]"
            case '*'
              __wt_open "$argv[1]"
          end
        end
      '';
    };
  };
}
