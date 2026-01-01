{
  config,
  pkgs,
  lib,
  me,
  ...
}: let
  # Create the exporter script with substitutions
  exporterScript = pkgs.replaceVars ./nixos-dotfiles-exporter.sh {
    __DOTFILES_PATH__ = "${me.homePrefix}/dotfiles";
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
    
    # Set PATH to include necessary tools
    export PATH="${lib.makeBinPath [pkgs.coreutils pkgs.gnused pkgs.git pkgs.nettools pkgs.moreutils]}:$PATH"
    
    ${pkgs.bash}/bin/bash ${exporterScript} | ${pkgs.moreutils}/bin/sponge nixos-metrics.prom
  '';
}
