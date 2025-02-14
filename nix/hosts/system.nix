{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  #GC
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  programs.zsh.enable = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.zsh
    pkgs.wget
    pkgs.home-manager
    pkgs.nixd
    pkgs.nil
    pkgs.git
    pkgs.gh
    pkgs.starship
    pkgs.tmux
    pkgs.fzf
    pkgs._1password-cli
  ];

  # Fonts
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # SOPS
  sops.defaultSopsFile = ../secrets/secrets.enc.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "home/nixos/.config/sops/age/keys.txt";

  sops.secrets = {
    "op_service_account/token" = { };
  };
}
