{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.myModules.home.plannotator;
  system = pkgs.stdenv.hostPlatform.system;
  plannotatorPkg = inputs.self.packages.${system}.plannotator-opencode-plugin;
in {
  options.myModules.home.plannotator = {
    enable = lib.mkEnableOption "plannotator OpenCode plugin";
  };

  config = lib.mkIf (cfg.enable && config.myModules.home.opencode.enable) {
    xdg.configFile."opencode/plugins/plannotator.js".source = "${plannotatorPkg}/plugins/plannotator.js";
    xdg.configFile."opencode/command/plannotator-review.md".source = "${plannotatorPkg}/commands/plannotator-review.md";
    xdg.configFile."opencode/command/plannotator-annotate.md".source = "${plannotatorPkg}/commands/plannotator-annotate.md";
    xdg.configFile."opencode/command/plannotator-last.md".source = "${plannotatorPkg}/commands/plannotator-last.md";
  };
}
