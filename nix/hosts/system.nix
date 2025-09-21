{
  config,
  pkgs,
  me,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  #GC
  nix = {
    gc =
      {
        automatic = true;
        options = "--delete-older-than 30d";
      }
      // (
        if pkgs.stdenv.isLinux
        then {
          dates = "weekly";
        }
        else {
          interval = {
            Weekday = 0;
            Hour = 0;
            Minute = 0;
          };
        }
      );
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

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
    pkgs.neovim
    pkgs.difftastic
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.argocd
  ];

  # Fonts
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.iosevka
  ];

  programs.zsh = {
    enable = true;
  };
}
