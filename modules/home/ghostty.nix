{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.ghostty;
in {
  options.myModules.home.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal configuration";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    programs.ghostty = {
      enable = true;
      package = null; # Installed via homebrew on Darwin
      settings = {
        font-size = 12;
      };
    };
  };
}
