{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.monitoring.exporters;
in {
  imports = [
    ./services/nixos-exporter.nix
    ./services/dotfiles-git-exporter.nix
  ];

  options.myModules.system.monitoring.exporters = {
    enable = lib.mkEnableOption "Prometheus exporters";

    nodeExporter = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable node exporter for system metrics";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = lib.mkIf cfg.nodeExporter.enable {
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
  };
}
