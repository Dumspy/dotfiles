{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}: let
  cfg = config.myModules.home.agent-browser;
  llm-agents-pkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.myModules.home.agent-browser = {
    enable = lib.mkEnableOption "agent-browser CLI for browser automation";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [llm-agents-pkgs.agent-browser];
  };
}
