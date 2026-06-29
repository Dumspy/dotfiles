{
  pkgs,
  lib,
  inputs,
  isDarwin ? false,
  isWsl ? false,
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
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;

    extra-substituters = [
      "https://cache.numtide.com"
      "https://auxera.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "auxera.cachix.org-1:47t8ocmmQE2OyAEipk98QQsAqG9GFz+5yQ4Ey1AjIHM="
    ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.wget
      pkgs.home-manager
      pkgs.nixd
      pkgs.nil
      pkgs.git
      pkgs.gh
      pkgs.difftastic
      pkgs.kubectl
      pkgs.kubernetes-helm
      pkgs.jq
      inputs.opnix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    # User-facing tools (starship/tmux/fzf/neovim) are owned by home-manager on
    # workstations (darwin/wsl). Install them at system level only on hosts
    # without home-manager (the k3s/oci servers) so they're available when SSHing
    # in but not double-installed where home-manager already provides them.
    ++ lib.optionals (!isDarwin && !isWsl) [
      pkgs.starship
      pkgs.tmux
      pkgs.fzf
      pkgs.neovim
    ];

  # Fonts
  fonts.packages =
    [pkgs.nerd-fonts.jetbrains-mono]
    # Workstation-only fonts (servers are headless): sans/serif/emoji per AGENTS.md theming.
    ++ lib.optionals (isDarwin || isWsl) [
      pkgs.inter
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji
    ];

  # Default system shell. The option itself defaults to "zsh" (see
  # modules/system/shell.nix); per-host files override this where needed.
  # zsh is kept enabled everywhere as a bare fallback shell.
}
