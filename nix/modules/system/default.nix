{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./onepassword.nix
    ./1password-agent.nix
    ./tailscale.nix
    ./k3s.nix
    ./traefik.nix
    ./monitoring
    ./openssh.nix
  ];
}
