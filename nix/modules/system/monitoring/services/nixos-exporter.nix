{
  config,
  pkgs,
  lib,
  ...
}: {
  # NixOS metrics - runs on every system activation (boot/rebuild)
  system.activationScripts.node-exporter-nixos = let
    nixosExporter = pkgs.writeShellScript "nixos-exporter" ''
      set -euo pipefail

      HOSTNAME=$(hostname)

      # Get NixOS generation from profile link
      CURRENT_GEN=$(readlink /nix/var/nix/profiles/system | sed 's/.*-\([0-9]*\)-link/\1/' || echo "0")

      # Get last rebuild timestamp
      REBUILD_TIME=$(stat -c '%Y' /run/current-system)

      # Output Prometheus metrics
      cat <<EOF
      # HELP nixos_generation_current Current NixOS system generation
      # TYPE nixos_generation_current gauge
      nixos_generation_current{hostname="$HOSTNAME"} $CURRENT_GEN

      # HELP nixos_last_rebuild_timestamp Last system rebuild Unix timestamp
      # TYPE nixos_last_rebuild_timestamp gauge
      nixos_last_rebuild_timestamp{hostname="$HOSTNAME"} $REBUILD_TIME
      EOF
    '';
  in ''
    mkdir -pm 0775 /var/lib/node_exporter/textfile_collector
    cd /var/lib/node_exporter/textfile_collector
    ${nixosExporter} | ${pkgs.moreutils}/bin/sponge nixos.prom
  '';
}
