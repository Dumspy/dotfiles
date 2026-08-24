{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.hunk;
in {
  options.myModules.home.hunk = {
    enable = lib.mkEnableOption "hunk, a terminal-first diff viewer";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Hunk config.toml settings, see https://hunk.dev/docs/";
    };

    enableGitIntegration = lib.mkEnableOption "hunk as the default git pager";
  };

  config = lib.mkIf cfg.enable {
    programs.hunk = {
      enable = true;
      settings = cfg.settings;
      enableGitIntegration = cfg.enableGitIntegration;
    };
  };
}
