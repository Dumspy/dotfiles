{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "24.05";

  programs.nix-ld.enable = true;
  users.defaultUserShell = pkgs.zsh;

  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.wslConf.network.generateResolvConf = false;

  # Enable Docker
  virtualisation.docker.enable = true;
  users.users.nixos.extraGroups = ["docker"];

  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = ["~."];
    dnsovertls = "false";
  };

  environment.systemPackages = [
    pkgs.socat # required for ssh pipe from Windows to WSL
    pkgs.gcc
    pkgs.gnumake
    pkgs.wslu # add wslu package
  ];

  # Set default browser for WSL
  environment.variables = {
    BROWSER = "wslview";
  };
}
