{
  config,
  lib,
  pkgs,
  vercel-agent-skills,
  expo-agent-skills,
  agent-browser,
  anthropics-agent-skills,
  dex-agent-skills,
  sentry-skills,
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
        path = vercel-agent-skills;
        skillsSubdir = "skills";
      };
      expo = {
        path = expo-agent-skills;
        skillsSubdir = "plugins/expo-app-design/skills";
      };
      agent-browser = {
        path = agent-browser;
        skillsSubdir = "skills/agent-browser";
      };
      anthropic-skills = {
        path = anthropics-agent-skills;
        skillsSubdir = "skills";
      };
      dex = {
        path = dex-agent-skills;
        skillsSubdir = "plugins/dex/skills";
      };
      sentry = {
        path = sentry-skills;
        skillsSubdir = "plugins/sentry-skills/skills";
      };
    };

    # Agents to enable (auto-discovered from sources)
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
