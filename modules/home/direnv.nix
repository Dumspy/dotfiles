{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.direnv;
  portable = config.myModules.home.portable or false;
in {
  options.myModules.home.direnv = {
    enable = lib.mkEnableOption "direnv with nix-direnv integration";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = config.myModules.home.zsh.enable && !portable;
      enableFishIntegration = config.myModules.home.fish.enable;
    };
  };
}
