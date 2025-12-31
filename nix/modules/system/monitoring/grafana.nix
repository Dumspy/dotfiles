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
    };
  };

  # Allow Grafana port through firewall
  networking.firewall.allowedTCPPorts = [2342];
}
