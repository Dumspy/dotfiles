{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.plannotator;
in {
  options.myModules.home.plannotator = {
    enable = lib.mkEnableOption "plannator OpenCode plugin";

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables exported for Plannator";
    };
  };

  config = lib.mkIf (cfg.enable && config.myModules.home.opencode.enable) {
    programs.plannotator-opencode-plugin.enable = true;
    programs.plannotator-opencode-plugin.env = cfg.env;
  };
}
