{
  config,
  lib,
  isDarwin ? false,
  ...
}: {
  imports =
    [
      ./onepassword.nix
      ./1password-agent.nix
      ./tailscale.nix
      ./openssh.nix
    ]
    ++ (
      if !isDarwin
      then [./k3s.nix]
      else []
    )
    ++ (
      if !isDarwin
      then [./traefik.nix]
      else []
    )
    ++ (
      if !isDarwin
      then [./monitoring]
      else []
    );
}
