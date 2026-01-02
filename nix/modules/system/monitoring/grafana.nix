{
  config,
  pkgs,
  lib,
  ...
}: {
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.internal.rger.dev";
      http_port = 2342;
      http_addr = "0.0.0.0";
    };

    provision = {
      enable = true;

      # Auto-provision Prometheus datasource
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

      # Auto-provision dashboards
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

  # Allow Grafana port through firewall
  networking.firewall.allowedTCPPorts = [2342];
}
