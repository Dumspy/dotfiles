{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.direnv;
in {
  options.myModules.home.direnv = {
    enable = lib.mkEnableOption "direnv with nix-direnv integration";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };
}
