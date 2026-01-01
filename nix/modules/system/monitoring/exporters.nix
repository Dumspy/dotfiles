{
  config,
  pkgs,
  lib,
  me,
  ...
}: {
  imports = [
    ./services/nixos-exporter.nix
    ./services/dotfiles-git-exporter.nix
  ];

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
}
