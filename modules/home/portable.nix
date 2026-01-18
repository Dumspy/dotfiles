{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
    ./direnv.nix
    ./git.nix
    ./ghostty.nix
    ./neovim.nix
    ./tmux.nix
    ./tmux-sessionizer.nix
    ./ssh.nix
  ];

  myModules.home = {
    zsh.enable = true;
    starship.enable = true;
    fzf.enable = true;
    direnv.enable = true;
    git.enable = true;
    ghostty.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    tmux-sessionizer.enable = true;
  };

  programs.home-manager.enable = true;
}
