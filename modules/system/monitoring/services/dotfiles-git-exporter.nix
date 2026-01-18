{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.monitoring.dotfiles-git-exporter;
in {
  options.myModules.system.monitoring.dotfiles-git-exporter = {
    enable = lib.mkEnableOption "Dotfiles Git metrics exporter";

    dotfilesPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to dotfiles repository";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.dotfiles-git-exporter = {
      description = "Export dotfiles Git metrics for Prometheus";
      after = ["network.target"];
      path = with pkgs; [git coreutils gnused nettools];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "dotfiles-git-exporter" ''
          set -euo pipefail

          HOSTNAME=$(hostname)
          DOTFILES_PATH="${cfg.dotfilesPath}"

          # Allow git to access dotfiles directory
          export GIT_CONFIG_COUNT=1
          export GIT_CONFIG_KEY_0="safe.directory"
          export GIT_CONFIG_VALUE_0="$DOTFILES_PATH"

          if [ -d "$DOTFILES_PATH/.git" ]; then
            cd "$DOTFILES_PATH"

            GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
            GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

            if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
              GIT_DIRTY=0
            else
              GIT_DIRTY=1
            fi

            git fetch origin 2>/dev/null || true
            COMMITS_BEHIND=$(git rev-list --count HEAD..origin/$GIT_BRANCH 2>/dev/null || echo 0)
          else
            GIT_BRANCH="unknown"
            GIT_COMMIT="unknown"
            GIT_DIRTY=0
            COMMITS_BEHIND=0
          fi

          cat <<EOF | ${pkgs.moreutils}/bin/sponge /var/lib/node_exporter/textfile_collector/dotfiles-git.prom
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
        '';
      };
    };

    systemd.timers.dotfiles-git-exporter = {
      description = "Timer for dotfiles Git metrics exporter";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
        Unit = "dotfiles-git-exporter.service";
      };
    };
  };
}
