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
    ++ lib.optionals (!isDarwin) [
      ./1password-agent.nix
      ./k3s.nix
      ./nix-netrc.nix
      ./rex.nix
      ./deploy.nix
    ];
}
