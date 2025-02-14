{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;

    initExtra = ''
      bindkey -s ^f "~/scripts/tmux-sessionizer\n"
    '';
  };
}
