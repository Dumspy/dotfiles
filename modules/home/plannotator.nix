{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.plannotator;
  plannotator-plugin = inputs.auxera.packages.${pkgs.stdenv.hostPlatform.system}.plannotator-opencode-plugin;
in {
  options.myModules.home.plannotator = {
    enable = lib.mkEnableOption "plannotator OpenCode plugin";

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables exported for Plannotator";
    };
  };

  config = lib.mkIf (cfg.enable && config.myModules.home.opencode.enable) {
    programs.opencode.extraPackages = [plannotator-plugin];

    programs.opencode.settings = {
      plugin = [
        "plannotator-opencode-plugin"
      ];
    };
  };
}
