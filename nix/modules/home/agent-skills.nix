{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myModules.home.agent-skills;
  agent-skills-lib = inputs.agent-skills-nix.lib.agent-skills {
    inherit inputs lib;
  };
in
{
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
        path = ../../../skills;
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

      skills.enable = [
        "example-skill"

        # Vercel
        "react-best-practices"
        "web-design-guidelines"

        # Expo
        "api-routes"
        "building-ui"
        "data-fetching"
        "dev-client"
        "tailwind-setup"
        "use-dom"
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
