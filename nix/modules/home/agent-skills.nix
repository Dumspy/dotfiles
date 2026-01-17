{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  agent-skills-lib = inputs.agent-skills-nix.lib.agent-skills {
    inherit inputs lib;
  };
in {
  imports = [
    inputs.agent-skills-nix.homeManagerModules.default
  ];

  programs.agent-skills = {
    enable = true;

    # Local skills source - points to skills directory in dotfiles root
    sources.local = {
      path = ../../../skills;
      subdir = ".";
    };

    # Vercel agent skills repository
    sources.vercel = {
      path = inputs.vercel-agent-skills;
      subdir = "skills";
    };

    # Expo agent skills repositories
    sources.expo-app-design = {
      path = inputs.expo-agent-skills;
      subdir = "plugins/expo-app-design/skills";
    };

    # Enable skills from various sources
    skills.enable = [
      # Local skills (add your own here)
      "example-skill"

      # Vercel skills
      "react-best-practices"
      "web-design-guidelines"

      # Expo skills - app design
      "api-routes"
      "building-ui"
      "data-fetching"
      "dev-client"
      "tailwind-setup"
      "use-dom"
    ];

    # Deploy skills to OpenCode's native location
    targets = {
      opencode = {
        dest = ".config/opencode/skill";
        structure = "symlink-tree";
      };
    };
  };
}
