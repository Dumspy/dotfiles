{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.claude-code;
in {
  options.myModules.home.claude-code = {
    enable = lib.mkEnableOption "Claude Code, Anthropic's official CLI";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
    };
  };
}
