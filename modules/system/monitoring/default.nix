{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}: {
  imports = lib.optionals (!isDarwin) [
    ./exporters.nix
    ./grafana.nix
    ./prometheus.nix
  ];
}
