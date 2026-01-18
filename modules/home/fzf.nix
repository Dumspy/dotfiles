{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.fzf;
in {
  options.myModules.home.fzf = {
    enable = lib.mkEnableOption "fzf fuzzy finder";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
