{ config, lib, pkgs, ... }:
{
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
}