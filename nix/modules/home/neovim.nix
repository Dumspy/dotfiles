{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.neovim;
in {
  options.myModules.home.neovim = {
    enable = lib.mkEnableOption "neovim with catppuccin theme";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        catppuccin-nvim
      ];

      extraConfig = ''
        packadd! catppuccin-nvim
        lua << EOF
        require('catppuccin').setup({
            flavour = "macchiato"
        })
        vim.cmd[[colorscheme catppuccin]]
        EOF
      '';
    };
  };
}
