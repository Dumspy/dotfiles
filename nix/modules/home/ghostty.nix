{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.ghostty;
  isDarwin = pkgs.stdenv.isDarwin;
in {
  options.myModules.home.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal configuration";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "Catppuccin Macchiato";
      description = "Ghostty color theme";
    };
  };

  config = lib.mkIf (cfg.enable && isDarwin) {
    programs.ghostty = {
      enable = true;
      package = null; # Installed via homebrew on Darwin
      settings = {
        theme = cfg.theme;
      };
    };
  };
}
