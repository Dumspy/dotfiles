{
  config,
  pkgs,
  lib,
  me,
  ...
}: let
  # Create the exporter script with substitutions
  exporterScript = pkgs.substituteAll {
    src = ./nixos-dotfiles-exporter.sh;
    isExecutable = true;
    __DOTFILES_PATH__ = "${me.homePrefix}/dotfiles";
    inherit (pkgs) bash git coreutils gnused hostname;
  };
in {
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

  # Run exporter on every system activation (boot/rebuild)
  system.activationScripts.nixos-dotfiles-metrics = ''
    mkdir -pm 0775 /var/lib/node_exporter/textfile_collector

    cd /var/lib/node_exporter/textfile_collector
    ${exporterScript} | ${pkgs.moreutils}/bin/sponge nixos-metrics.prom
  '';
}
