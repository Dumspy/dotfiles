{
  config,
  pkgs,
  ...
}: {
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  imports = [
    ../modules/home/zsh.nix
    ../modules/home/starship.nix
    ../modules/home/fzf.nix
    ../modules/home/git.nix
    ../modules/home/direnv.nix
    ../modules/home/neovim.nix
    ../modules/home/tmux.nix
  ];

  home.file = {
    ".gitignore_global".source = ../../git/.gitignore_global;
    "scripts/tmux-sessionizer" = {
      source = ../../scripts/tmux-sessionizer;
      executable = true;
    };
  };

  programs.home-manager.enable = true;
}
