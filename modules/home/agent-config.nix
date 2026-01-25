{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.myModules.home.agent-config;
  portable = config.myModules.home.portable or false;

  # Build a derivation containing selected agents from sources
  mkAgentsBundle = sources: let
    agentFiles = lib.flatten (lib.mapAttrsToList (
        sourceName: sourceSpec: let
          basePath = sourceSpec.path;
          subdir = sourceSpec.agentsSubdir;
        in
          map (agentName: {
            inherit sourceName agentName;
            src = "${basePath}/${subdir}/${agentName}.md";
          })
          sourceSpec.agents
      )
      (lib.filterAttrs (_: s: s.agents != []) sources));
  in
    pkgs.runCommand "agents-bundle" {} ''
      mkdir -p $out
      ${lib.concatMapStringsSep "\n" (agent: ''
          if [ -f "${agent.src}" ]; then
            cp "${agent.src}" "$out/${agent.agentName}.md"
          else
            echo "Warning: Agent file not found: ${agent.src}" >&2
          fi
        '')
        agentFiles}
    '';

  # Source submodule type (supports both skills and agents)
  sourceType = lib.types.submodule {
    options = {
      path = lib.mkOption {
        type = lib.types.path;
        description = "Path to the flake input or local directory";
      };
      skillsSubdir = lib.mkOption {
        type = lib.types.str;
        default = "skills";
        description = "Subdirectory for skills (directories with SKILL.md)";
      };
      agentsSubdir = lib.mkOption {
        type = lib.types.str;
        default = "agents";
        description = "Subdirectory for agents (.md files)";
      };
      agents = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of agent names to enable (without .md extension)";
      };
    };
  };

  targetType = lib.types.submodule {
    options = {
      dest = lib.mkOption {
        type = lib.types.str;
        description = "Destination path relative to home directory";
      };
      structure = lib.mkOption {
        type = lib.types.enum ["link" "symlink-tree" "copy-tree"];
        default = "symlink-tree";
        description = "How to install: link, symlink-tree, or copy-tree";
      };
    };
  };
in {
  imports = [
    inputs.agent-skills-nix.homeManagerModules.default
  ];

  options.myModules.home.agent-config = {
    enable = lib.mkEnableOption "unified agent configuration (skills + agents)";

    sources = lib.mkOption {
      type = lib.types.attrsOf sourceType;
      default = {};
      description = "Named sources for skills and agents";
    };

    skills = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of skill names to enable (autodiscovered from sources)";
    };

    localSkills = lib.mkOption {
      type = lib.types.path;
      default = ../../ai/skills;
      description = "Path to local skills directory";
    };

    localAgents = lib.mkOption {
      type = lib.types.path;
      default = ../../ai/agents;
      description = "Path to local agents directory";
    };

    skillsTarget = lib.mkOption {
      type = targetType;
      default = {
        dest = ".config/opencode/skill";
        structure =
          if portable
          then "link"
          else "symlink-tree";
      };
      description = "Target for skills installation";
    };

    agentsTarget = lib.mkOption {
      type = targetType;
      default = {
        dest = ".config/opencode/agents";
        structure =
          if portable
          then "link"
          else "symlink-tree";
      };
      description = "Target for agents installation";
    };
  };

  config = lib.mkIf cfg.enable (let
    agentsBundle = mkAgentsBundle cfg.sources;

    skillsSources =
      lib.mapAttrs (name: spec: {
        path = spec.path;
        subdir = spec.skillsSubdir;
      })
      cfg.sources;
  in {
    # Default sources configuration
    myModules.home.agent-config.sources = {
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
      claude-plugins = {
        path = inputs.claude-plugins-official;
        skillsSubdir = "plugins";
        agentsSubdir = "plugins/code-simplifier/agents";
        agents = [
          "code-simplifier"
        ];
      };
    };

    # Default skills to enable
    myModules.home.agent-config.skills = [
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

    # Configure agent-skills-nix for skills
    programs.agent-skills = {
      enable = true;

      sources =
        {
          local = {
            path = cfg.localSkills;
            subdir = ".";
          };
        }
        // skillsSources;

      skills.enable = cfg.skills;

      targets.opencode = {
        dest = cfg.skillsTarget.dest;
        structure = cfg.skillsTarget.structure;
      };
    };

    # Handle agents with "link" structure
    home.file = lib.mkIf (cfg.agentsTarget.structure == "link") {
      "${cfg.agentsTarget.dest}" = {
        source = cfg.localAgents;
        recursive = true;
      };
    };

    # Use activation for symlink-tree and copy-tree agents
    home.activation = lib.mkIf (cfg.agentsTarget.structure != "link") {
      "install-agents" = lib.hm.dag.entryAfter ["writeBoundary"] (let
        destPath = "${config.home.homeDirectory}/${cfg.agentsTarget.dest}";
        rsyncFlags =
          if cfg.agentsTarget.structure == "symlink-tree"
          then "-a --delete"
          else "-aL --delete";
      in ''
        mkdir -p "${destPath}"
        ${pkgs.rsync}/bin/rsync ${rsyncFlags} "${cfg.localAgents}/" "${destPath}/"

        if [ -d "${agentsBundle}" ] && [ "$(ls -A ${agentsBundle})" ]; then
          ${pkgs.rsync}/bin/rsync ${rsyncFlags} "${agentsBundle}/" "${destPath}/"
        fi
      '');
    };
  });
}
