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
  ];

  # Fonts
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.iosevka
  ];

  # SOPS
  sops.defaultSopsFile = ../secrets/secrets.enc.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "${me.homePrefix}/.config/sops/age/keys.txt";

  sops.secrets = {
    "op_service_account/token" = {
      owner = "${me.username}";
    };
  };

  programs.zsh = {
    enable = true;
    shellInit = ''
      export OP_SERVICE_ACCOUNT_TOKEN="$(cat ${config.sops.secrets."op_service_account/token".path})"
    '';
  };
}
