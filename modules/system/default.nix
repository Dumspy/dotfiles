{
  config,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./onepassword.nix
      ./tailscale.nix
      ./openssh.nix
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      ./1password-agent.nix
      ./k3s.nix
      ./traefik.nix
      ./monitoring
    ];
}
