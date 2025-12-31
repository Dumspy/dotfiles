{
  config,
  pkgs,
  lib,
  me,
  ...
}: {
  # Node exporter for system metrics
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "filesystem"
      "netdev"
      "textfile"
    ];
    port = 9100;
    listenAddress = "0.0.0.0";
    extraFlags = [
      "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"
    ];
  };

  # Create textfile collector directory  
  systemd.tmpfiles.rules = [
    "d /var/lib/node_exporter/textfile_collector 0755 root root -"
  ];

  # Custom NixOS and dotfiles metrics exporter
  systemd.services.nixos-metrics-exporter = {
    description = "Export NixOS and dotfiles Git metrics for Prometheus";
    after = ["prometheus-node-exporter.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "nixos-metrics-exporter" ''
                set -euo pipefail

                TEXTFILE_DIR="/var/lib/node_exporter/textfile_collector"
                DOTFILES_PATH="${me.homePrefix}/dotfiles"
                HOSTNAME=$(${pkgs.hostname}/bin/hostname)
                TEMP_FILE="$TEXTFILE_DIR/nixos_metrics.prom.$$"
                FINAL_FILE="$TEXTFILE_DIR/nixos_metrics.prom"

                # Get NixOS metrics
                # Get current generation from profile link
                current_gen=$(${pkgs.coreutils}/bin/readlink /nix/var/nix/profiles/system | ${pkgs.gnused}/bin/sed 's/.*-\([0-9]*\)-link/\1/' || echo "0")
                # Get channel info (may not be available on flake systems)
                channel=$(${pkgs.nix}/bin/nix-channel --list 2>/dev/null | ${pkgs.gnugrep}/bin/grep nixpkgs | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.gnused}/bin/sed 's/.*\///' || echo "flake")
                rebuild_time=$(${pkgs.coreutils}/bin/stat -c %Y /run/current-system)

                # Get dotfiles Git metrics
                if [ -d "$DOTFILES_PATH/.git" ]; then
                  cd "$DOTFILES_PATH"
                  git_branch=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
                  git_commit=$(${pkgs.git}/bin/git rev-parse --short HEAD 2>/dev/null || echo "unknown")

                  # Check if repo is dirty
                  if ${pkgs.git}/bin/git diff --quiet 2>/dev/null && ${pkgs.git}/bin/git diff --cached --quiet 2>/dev/null; then
                    git_dirty=0
                  else
                    git_dirty=1
                  fi

                  # Check commits behind (requires network, may fail)
                  commits_behind=$(${pkgs.git}/bin/git fetch origin 2>/dev/null && ${pkgs.git}/bin/git rev-list --count HEAD..origin/$git_branch 2>/dev/null || echo 0)
                else
                  git_branch="unknown"
                  git_commit="unknown"
                  git_dirty=0
                  commits_behind=0
                fi

                # Write metrics in Prometheus format
                cat > "$TEMP_FILE" <<EOF
        # HELP nixos_generation_current Current NixOS system generation
        # TYPE nixos_generation_current gauge
        nixos_generation_current{hostname="$HOSTNAME"} $current_gen

        # HELP nixos_last_rebuild_timestamp Last system rebuild Unix timestamp
        # TYPE nixos_last_rebuild_timestamp gauge
        nixos_last_rebuild_timestamp{hostname="$HOSTNAME"} $rebuild_time

        # HELP dotfiles_git_info Dotfiles Git branch and commit info
        # TYPE dotfiles_git_info gauge
        dotfiles_git_info{hostname="$HOSTNAME",branch="$git_branch",commit="$git_commit"} 1

        # HELP dotfiles_git_commits_behind Number of commits behind remote
        # TYPE dotfiles_git_commits_behind gauge
        dotfiles_git_commits_behind{hostname="$HOSTNAME",remote="origin",branch="$git_branch"} $commits_behind

        # HELP dotfiles_git_dirty Whether dotfiles repo has uncommitted changes
        # TYPE dotfiles_git_dirty gauge
        dotfiles_git_dirty{hostname="$HOSTNAME"} $git_dirty
        EOF

                # Atomic move
                ${pkgs.coreutils}/bin/mv "$TEMP_FILE" "$FINAL_FILE"
      '';
    };
  };

  # Timer to run metrics exporter every 5 minutes
  systemd.timers.nixos-metrics-exporter = {
    description = "Timer for NixOS metrics exporter";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Unit = "nixos-metrics-exporter.service";
    };
  };
}
