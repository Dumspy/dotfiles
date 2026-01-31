{...}: {
  home.stateVersion = "24.11";

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "mauve";
  };

  myModules.home = {
    shell.default = "zsh";
    starship.enable = true;
    fzf.enable = true;
    git.enable = true;
    direnv.enable = true;
    lazyvim.enable = true;
    tmux.enable = true;
    tmux-sessionizer.enable = true;
    tmux-worktree.enable = true;
    opencode.enable = true;
    agent-config.enable = true;
    agent-browser.enable = true;
    dex.enable = true;
    lazygit.enable = true;
    git-clone-bare.enable = true;
  };

  programs.home-manager.enable = true;
}
