{
  config,
  lib,
  isDarwin ? false,
  ...
}: {
  imports =
    (
      if !isDarwin
      then [./exporters.nix]
      else []
    )
    ++ (
      if !isDarwin
      then [./grafana.nix]
      else []
    )
    ++ (
      if !isDarwin
      then [./prometheus.nix]
      else []
    );
}
