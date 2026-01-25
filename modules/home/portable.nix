{
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
    ./neovim.nix
    ./tmux.nix
    ./tmux-sessionizer.nix
    ./opencode.nix
    ./agent-config.nix
    ./lazygit.nix
    ./ssh.nix
  ];

  myModules.home = {
    portable = true;
    zsh.enable = true;
    starship.enable = true;
    fzf.enable = true;
    direnv.enable = true;
    git.enable = true;
    ghostty.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    tmux-sessionizer.enable = true;
    opencode.enable = true;
    lazygit.enable = true;
    ssh.enable = true;
  };

  programs.home-manager.enable = true;
}
