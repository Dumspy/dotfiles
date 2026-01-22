{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.fish;
in {
  options.myModules.home.fish = {
    enable = lib.mkEnableOption "fish shell with plugins and completions";
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';

      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];

      shellAliases = {};
      shellAbbrs = {};
    };
  };
}
