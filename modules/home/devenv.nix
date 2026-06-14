{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.devenv;
in {
  options.myModules.home.devenv = {
    enable = lib.mkEnableOption "devenv developer environment CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.devenv];
  };
}
