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

      agents = [
        "code-simplifier"
        "librarian"
        "oracle"
      ];

      skills = [
        "dependabot-solver"
        "pr-review-resolver"

        # Anthropic
        "skill-creator"

        # Browser
        "agent-browser"
      ];
    };
  };
}
