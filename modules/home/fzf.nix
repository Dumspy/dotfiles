{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.fzf;
  portable = config.myModules.home.portable or false;
in {
  options.myModules.home.fzf = {
    enable = lib.mkEnableOption "fzf fuzzy finder";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = config.myModules.home.zsh.enable && !portable;
      enableFishIntegration = config.myModules.home.fish.enable;
    };
  };
}
