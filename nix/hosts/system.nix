{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

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
  ];

  # Fonts
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
