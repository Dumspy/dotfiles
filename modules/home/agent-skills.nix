{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.myModules.home.agent-skills;
  agent-skills-lib = inputs.agent-skills-nix.lib.agent-skills {
    inherit inputs lib;
  };
in {
  imports = [
    inputs.agent-skills-nix.homeManagerModules.default
  ];

  options.myModules.home.agent-skills = {
    enable = lib.mkEnableOption "agent-skills for AI coding assistants";
  };

  config = lib.mkIf cfg.enable {
    programs.agent-skills = {
      enable = true;

      sources.local = {
        path = ../../ai/skills;
        subdir = ".";
      };

      sources.vercel = {
        path = inputs.vercel-agent-skills;
        subdir = "skills";
      };

      sources.expo-app-design = {
        path = inputs.expo-agent-skills;
        subdir = "plugins/expo-app-design/skills";
      };

      sources.agent-browser = {
        path = inputs.agent-browser;
        subdir = "skills/agent-browser";
      };

      sources.anthropic-skills = {
        path = inputs.anthropics-agent-skills;
        subdir = "skills";
      };

      skills.enable = [
        "dependabot-solver"

        # Anthropic
        "skill-creator"
        "frontend-design"

        # Vercel
        "react-best-practices"
        "web-design-guidelines"

        # Expo
        "expo-api-routes"
        "building-native-ui"
        "native-data-fetching"
        "expo-dev-client"
        "expo-tailwind-setup"
        "use-dom"

        # Browser
        "agent-browser"
      ];

      targets = {
        opencode = {
          dest = ".config/opencode/skill";
          structure = "symlink-tree";
        };
      };
    };
  };
}
