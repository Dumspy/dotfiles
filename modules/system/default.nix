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
      ./nix-netrc.nix
    ]
    ++ lib.optionals (isDarwin || isWsl) [
      ./kubeconfig.nix
    ]
    ++ lib.optionals (!isDarwin) [
      ./1password-agent.nix
      ./k3s.nix
      ./rex.nix
      ./deploy.nix
    ];
}
