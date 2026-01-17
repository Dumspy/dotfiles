{
  config,
  pkgs,
  inputs,
  ...
}: let
  opencode = inputs.opencode;

  # List of skill repositories to install - add more repos here as needed
  skillRepos = [
    "vercel-labs/agent-skills"
    # Add additional repositories here:
    # "your-org/custom-skills"
    # "another-org/frontend-patterns"
  ];

  # Script to silently install opencode skills
  # Note: This trusts the listed skill repositories.
  # If any repository is compromised, malicious code could execute.
  # Only add repositories you trust completely.
  installScript = pkgs.writeShellScript "install-opencode-skills" ''
    for repo in ${pkgs.lib.escapeShellArgs skillRepos}; do
      if ! ${pkgs.bun}/bin/bunx add-skill "$repo" -a opencode --global -y >/dev/null 2>&1; then
        echo "[opencode-skills] Warning: Failed to install skill from $repo" >&2
      fi
    done
  '';
in {
  # Ensure bun is available for the activation script
  home.packages = [pkgs.bun];

  # Install opencode skills using tmpfiles (runs on rebuild)
  systemd.user.tmpfiles.rules = [
    "C ${config.home.homeDirectory}/.config/opencode/skill 0755 - - - ${installScript}"
  ];
  programs.opencode = {
    enable = true;
    package = opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      theme = "catppuccin-macchiato";
      autoupdate = false;

      # Add plugin
      plugin = ["opencode-antigravity-auth@latest"];

      # MCP Servers
      mcp = {
        grep_app = {
          type = "remote";
          url = "https://mcp.grep.app";
          enabled = true;
        };
      };

      # Provider configuration
      provider = {
        google = {
          models = {
            "antigravity-gemini-3-pro" = {
              name = "Gemini 3 Pro (Antigravity)";
              limit = {
                context = 1048576;
                output = 65535;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
              variants = {
                low = {thinkingLevel = "low";};
                high = {thinkingLevel = "high";};
              };
            };
            "antigravity-gemini-3-flash" = {
              name = "Gemini 3 Flash (Antigravity)";
              limit = {
                context = 1048576;
                output = 65536;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
              variants = {
                minimal = {thinkingLevel = "minimal";};
                low = {thinkingLevel = "low";};
                medium = {thinkingLevel = "medium";};
                high = {thinkingLevel = "high";};
              };
            };
            "antigravity-claude-sonnet-4-5" = {
              name = "Claude Sonnet 4.5 (Antigravity)";
              limit = {
                context = 200000;
                output = 64000;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
            };
            "antigravity-claude-sonnet-4-5-thinking" = {
              name = "Claude Sonnet 4.5 Thinking (Antigravity)";
              limit = {
                context = 200000;
                output = 64000;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
              variants = {
                low = {thinkingConfig = {thinkingBudget = 8192;};};
                max = {thinkingConfig = {thinkingBudget = 32768;};};
              };
            };
            "antigravity-claude-opus-4-5-thinking" = {
              name = "Claude Opus 4.5 Thinking (Antigravity)";
              limit = {
                context = 200000;
                output = 64000;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
              variants = {
                low = {thinkingConfig = {thinkingBudget = 8192;};};
                max = {thinkingConfig = {thinkingBudget = 32768;};};
              };
            };
            "gemini-2.5-flash" = {
              name = "Gemini 2.5 Flash (Gemini CLI)";
              limit = {
                context = 1048576;
                output = 65536;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
            };
            "gemini-2.5-pro" = {
              name = "Gemini 2.5 Pro (Gemini CLI)";
              limit = {
                context = 1048576;
                output = 65536;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
            };
            "gemini-3-flash-preview" = {
              name = "Gemini 3 Flash Preview (Gemini CLI)";
              limit = {
                context = 1048576;
                output = 65536;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
            };
            "gemini-3-pro-preview" = {
              name = "Gemini 3 Pro Preview (Gemini CLI)";
              limit = {
                context = 1048576;
                output = 65535;
              };
              modalities = {
                input = ["text" "image" "pdf"];
                output = ["text"];
              };
            };
          };
        };
      };

      # Security-focused tool permissions
      permission = {
        "read" = {
          "*" = "allow";
          ".direnv/*" = "deny";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.envrc" = "deny";
          "secrets/*" = "deny";
        };
        webfetch = "ask";
        bash = {
          "*" = "ask";
          "ls*" = "allow";
          "git status*" = "allow";
          "git diff*" = "allow";
          "git log*" = "allow";
        };
      };

      formatter = {
        alejandra = {
          command = [
            "alejandra"
            "$FILE"
          ];
          extensions = [".nix"];
        };
      };
    };

    rules = "";

    # Custom agents for specialized tasks
    agents = {
    };

    # Custom commands for common workflows
    commands = {
    };
  };
}
