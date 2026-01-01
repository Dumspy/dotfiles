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

  # NixOS metrics - runs on every system activation (boot/rebuild)
  system.activationScripts.node-exporter-nixos = let
    nixosExporter = pkgs.writeShellScript "nixos-exporter" (builtins.readFile ./nixos-exporter.sh);
  in ''
    mkdir -pm 0775 /var/lib/node_exporter/textfile_collector
    cd /var/lib/node_exporter/textfile_collector
    ${nixosExporter} | ${pkgs.moreutils}/bin/sponge nixos.prom
  '';

  # Dotfiles Git metrics - runs as a systemd service every 5 minutes
  systemd.services.dotfiles-git-exporter = {
    description = "Export dotfiles Git metrics for Prometheus";
    after = ["network.target"];
    path = with pkgs; [git coreutils];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        exporterScript = pkgs.replaceVars ./dotfiles-git-exporter.sh {
          __DOTFILES_PATH__ = "${me.homePrefix}/dotfiles";
        };
      in pkgs.writeShellScript "dotfiles-git-exporter-wrapper" ''
        # Allow git to access dotfiles directory
        export GIT_CONFIG_COUNT=1
        export GIT_CONFIG_KEY_0="safe.directory"
        export GIT_CONFIG_VALUE_0="${me.homePrefix}/dotfiles"
        
        # Log debug output to a separate file
        ${exporterScript} 2>/var/lib/node_exporter/textfile_collector/dotfiles-git-debug.log | ${pkgs.moreutils}/bin/sponge /var/lib/node_exporter/textfile_collector/dotfiles-git.prom
        
        echo "Last run: $(date)" >> /var/lib/node_exporter/textfile_collector/dotfiles-git-debug.log
      '';
    };
  };

  # Timer to run git metrics exporter every 5 minutes
  systemd.timers.dotfiles-git-exporter = {
    description = "Timer for dotfiles Git metrics exporter";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Unit = "dotfiles-git-exporter.service";
    };
  };
}
