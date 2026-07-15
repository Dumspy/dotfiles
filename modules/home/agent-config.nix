{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.dot-agents.homeModules.default
  ];

  options.myModules.home.agent-config = {
    enable = lib.mkEnableOption "unified agent configuration (skills + agents)";
  };

  config = lib.mkIf config.myModules.home.agent-config.enable {
    programs.dot-agents = {
      enable = true;
      pi.externalExtensions = null;
    };
  };
}
