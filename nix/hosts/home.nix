{
  config,
  pkgs,
  ...
}: {
  home.stateVersion = "24.11";

  myModules.home = {
    zsh.enable = true;
    starship.enable = true;
    fzf.enable = true;
    git.enable = true;
    direnv.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    tmux-sessionizer.enable = true;
    opencode.enable = true;
    agent-skills.enable = true;
  };

  home.file = {
    ".gitignore_global".source = ../../git/.gitignore_global;
  };

  programs.home-manager.enable = true;
}
