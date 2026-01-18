{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.monitoring.grafana;
in {
  options.myModules.system.monitoring.grafana = {
    enable = lib.mkEnableOption "Grafana dashboard";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "grafana.internal.rger.dev";
      description = "Domain for Grafana";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2342;
      description = "Port for Grafana HTTP server";
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings.server = {
        domain = cfg.domain;
        http_port = cfg.port;
        http_addr = "0.0.0.0";
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
            jsonData = {
              timeInterval = "15s";
            };
          }
        ];

        dashboards.settings = {
          apiVersion = 1;
          providers = [
            {
              name = "System Monitoring";
              type = "file";
              disableDeletion = false;
              updateIntervalSeconds = 10;
              allowUiUpdates = true;
              options = {
                path = ./dashboards;
                foldersFromFilesStructure = false;
              };
            }
          ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
