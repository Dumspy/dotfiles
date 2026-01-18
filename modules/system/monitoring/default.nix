{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = lib.optionals (!pkgs.stdenv.isDarwin) [
    ./exporters.nix
    ./grafana.nix
    ./prometheus.nix
  ];
}
