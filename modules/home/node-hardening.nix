{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.node-hardening;
in {
  options.myModules.home.node-hardening = {
    enable = lib.mkEnableOption "Node.js supply-chain security hardening";
  };

  config = lib.mkIf cfg.enable {
    programs.npm = {
      enable = true;
      package = null;
      settings = {
        min-release-age = 7;
        save-exact = true;
        ignore-scripts = true;
      };
    };

    programs.bun = {
      enable = true;
      package = null;
      settings = {
        install = {
          minimumReleaseAge = 604800;
          ignoreScripts = true;
          exact = true;
        };
      };
    };

    programs.yarn = {
      enable = true;
      settings = {
        enableScripts = false;
        defaultSemverRangePrefix = "";
        npmMinimalAgeGate = "7d";
      };
    };
  };
}
