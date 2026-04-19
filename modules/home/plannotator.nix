{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.plannotator;
in {
  options.myModules.home.plannotator = {
    enable = lib.mkEnableOption "plannotator OpenCode plugin";

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables exported for Plannotator.";
    };
  };

  config = lib.mkIf (cfg.enable && config.myModules.home.opencode.enable) {
    programs.plannotator-opencode-plugin = {
      enable = true;
      env = cfg.env;
    };
  };
}
