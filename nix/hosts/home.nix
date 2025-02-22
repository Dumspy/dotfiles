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
    ../modules/zsh.nix
    ../modules/starship.nix
    ../modules/fzf.nix
    ../modules/git.nix
    ../modules/direnv.nix
    ../modules/neovim.nix
  ];

  home.file = {
    ".gitignore_global".source = ../../git/.gitignore_global;
    ".config/tmux/tmux.conf".source = ../../tmux/tmux.conf;
    "scripts/".source = ../../scripts;
  };

  programs.home-manager.enable = true;
}
