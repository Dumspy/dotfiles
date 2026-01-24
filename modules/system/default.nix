{
  lib,
  isDarwin,
  ...
}: {
  imports =
    [
      ./shell.nix
      ./onepassword.nix
      ./tailscale.nix
      ./openssh.nix
    ]
    ++ lib.optionals (!isDarwin) [
      ./1password-agent.nix
      ./k3s.nix
      ./traefik.nix
      ./monitoring
    ];
}
