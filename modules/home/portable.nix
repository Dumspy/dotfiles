{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./options.nix
    ./shell.nix
    ./zsh.nix
    ./fish.nix
    ./starship.nix
    ./fzf.nix
    ./direnv.nix
    ./git.nix
    ./ghostty.nix
    ./lazyvim.nix
    ./tmux.nix
    ./tmux-sessionizer.nix
    ./tmux-worktree.nix
    ./git-clone-bare.nix
    ./opencode.nix
    ./agent-config.nix
    ./lazygit.nix
    ./ssh.nix
  ];

  home.username = "__PORTABLE_USER__";
  home.homeDirectory = "/__PORTABLE_HOME__";
  home.stateVersion = "24.11";

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "mauve";
  };

  myModules.home = {
    portable = true;
    zsh.enable = true;
    starship.enable = true;
    fzf.enable = true;
    direnv.enable = false;
    git.enable = true;
    ghostty.enable = true;
    lazyvim.enable = true;
    tmux.enable = true;
    tmux-sessionizer.enable = true;
    tmux-worktree.enable = true;
    git-clone-bare.enable = true;
    opencode.enable = true;
    agent-config.enable = true;
    lazygit.enable = true;
    ssh.enable = false;
  };

  programs.home-manager.enable = true;
}
