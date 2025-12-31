{
  config,
  pkgs,
  lib,
  ...
}: {
  services.grafana = {
    enable = true;
    domain = "grafana.internal.rger.dev";
    port = 2342;
    addr = "127.0.0.1";

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
}
