{
  config,
  pkgs,
  lib,
  ...
}: {
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";
    retentionTime = "15d";

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "master-node:9100"
              "k3s-node:9100"
            ];
          }
        ];
        scrape_interval = "15s";
      }
    ];

    # Recording rules for common queries (optional, can be extended)
    rules = [];
  };
}
