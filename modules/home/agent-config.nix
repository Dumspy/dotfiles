{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    (import ../../lib/agent-config.nix {inherit lib pkgs config;})
  ];

  config.myModules.home.agent-config = {
    localSkills = ../../ai/skills;
    localAgents = ../../ai/agents;

    sources = {
      vercel = {
        path = inputs.vercel-agent-skills;
        skillsSubdir = "skills";
      };
      expo = {
        path = inputs.expo-agent-skills;
        skillsSubdir = "plugins/expo-app-design/skills";
      };
      agent-browser = {
        path = inputs.agent-browser;
        skillsSubdir = "skills/agent-browser";
      };
      anthropic-skills = {
        path = inputs.anthropics-agent-skills;
        skillsSubdir = "skills";
      };
      dex = {
        path = inputs.dex-agent-skills;
        skillsSubdir = "plugins/dex/skills";
      };
      sentry = {
        path = inputs.sentry-skills;
        skillsSubdir = "plugins/sentry-skills/skills";
        agentsSubdir = "plugins/sentry-skills/agents";
      };
    };

    # Agents to enable (auto-discovered from sources)
    agents = [
      # "code-simplifier" # from sentry
    ];

    skills = [
      "dependabot-solver"
      "pr-review-resolver"

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

      # Dex
      "dex"
      "dex-plan"

      # Sentry
      "doc-coauthoring"
    ];
  };
}
