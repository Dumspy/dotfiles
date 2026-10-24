{
  lib,
  isDarwin,
  isWsl,
  ...
}: {
  imports =
    [
      ./shell.nix
      ./onepassword.nix
      ./tailscale.nix
      ./openssh.nix
    ]
    ++ lib.optionals (isDarwin || isWsl) [
      ./kubeconfig.nix
    ]
    ++ lib.optionals isWsl [
      ./1password-agent.nix
    ]
    ++ lib.optionals (!isDarwin) [
      ./k3s.nix
      ./deploy.nix
    ];
}
