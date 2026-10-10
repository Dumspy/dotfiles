{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.llama-cpp;
in {
  options.myModules.home.llama-cpp = {
    enable = lib.mkEnableOption "llama.cpp local inference (Metal on Darwin)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.llama-cpp];
  };
}
