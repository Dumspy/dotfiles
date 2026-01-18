{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.monitoring.prometheus;
in {
  options.myModules.system.monitoring.prometheus = {
    enable = lib.mkEnableOption "Prometheus monitoring";

    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Port for Prometheus server";
    };

    retentionTime = lib.mkOption {
      type = lib.types.str;
      default = "15d";
      description = "How long to retain metrics data";
    };

    scrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["master-node:9100" "k3s-node:9100"];
      description = "List of scrape targets (host:port format)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = cfg.port;
      listenAddress = "127.0.0.1";
      retentionTime = cfg.retentionTime;

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = cfg.scrapeTargets;
            }
          ];
          scrape_interval = "15s";
        }
      ];

      rules = [];
    };
  };
}
