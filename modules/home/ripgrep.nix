{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.ripgrep;
in {
  options.myModules.home.ripgrep = {
    enable = lib.mkEnableOption "ripgrep configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--max-filesize=5M"
      ];
    };
  };
}
