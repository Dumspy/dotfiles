{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.myModules.home.lazyvim;
in {
  imports = [inputs.lazyvim.homeManagerModules.default];

  options.myModules.home.lazyvim = {
    enable = lib.mkEnableOption "LazyVim editor";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      enable = true;
      installCoreDependencies = true;

      extras = {
        lang.nix.enable = true;
        lang.json.enable = true;
        lang.yaml.enable = true;
        lang.markdown.enable = true;
        lang.typescript.enable = true;
      };

      plugins.colorscheme = ''
        return {
          "catppuccin/nvim",
          name = "catppuccin",
          opts = {
            flavour = "macchiato",
            transparent_background = false,
          },
        }
      '';
    };

    home.sessionVariables.EDITOR = "nvim";
  };
}
