{...}: {
  home.stateVersion = "26.05";

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
    wt.enable = true;
    opencode.enable = true;
    pi = {
      enable = true;
      settings = {
        defaultProvider = "opencode-go";
        enableInstallTelemetry = false;
      };
    };
    plannotator.enable = true;
    agent-config.enable = true;
    agent-browser.enable = true;
    dex.enable = false;
    lazygit.enable = true;
    ripgrep.enable = true;
    node-hardening.enable = true;
  };

  programs.home-manager.enable = true;
}
