{
  config,
  lib,
  isDarwin ? false,
  ...
}: {
  imports =
    [
      ./onepassword.nix
      ./tailscale.nix
      ./openssh.nix
    ]
    ++ (
      if !isDarwin
      then [./1password-agent.nix]
      else []
    )
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
