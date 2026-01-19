{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myModules.home.opencode;
  opencode = inputs.opencode;
in
{
  options.myModules.home.opencode = {
    enable = lib.mkEnableOption "opencode AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;

      settings = {
        theme = "catppuccin-macchiato";
        autoupdate = false;

        plugin = [ "opencode-antigravity-auth@latest" ];

        mcp = {
          grep_app = {
            type = "remote";
            url = "https://mcp.grep.app";
            enabled = false;
          };
        };

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
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  low = {
                    thinkingLevel = "low";
                  };
                  high = {
                    thinkingLevel = "high";
                  };
                };
              };
              "antigravity-gemini-3-flash" = {
                name = "Gemini 3 Flash (Antigravity)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  minimal = {
                    thinkingLevel = "minimal";
                  };
                  low = {
                    thinkingLevel = "low";
                  };
                  medium = {
                    thinkingLevel = "medium";
                  };
                  high = {
                    thinkingLevel = "high";
                  };
                };
              };
              "antigravity-claude-sonnet-4-5" = {
                name = "Claude Sonnet 4.5 (Antigravity)";
                limit = {
                  context = 200000;
                  output = 64000;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "antigravity-claude-sonnet-4-5-thinking" = {
                name = "Claude Sonnet 4.5 Thinking (Antigravity)";
                limit = {
                  context = 200000;
                  output = 64000;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  low = {
                    thinkingConfig = {
                      thinkingBudget = 8192;
                    };
                  };
                  max = {
                    thinkingConfig = {
                      thinkingBudget = 32768;
                    };
                  };
                };
              };
              "antigravity-claude-opus-4-5-thinking" = {
                name = "Claude Opus 4.5 Thinking (Antigravity)";
                limit = {
                  context = 200000;
                  output = 64000;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  low = {
                    thinkingConfig = {
                      thinkingBudget = 8192;
                    };
                  };
                  max = {
                    thinkingConfig = {
                      thinkingBudget = 32768;
                    };
                  };
                };
              };
              "gemini-2.5-flash" = {
                name = "Gemini 2.5 Flash (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "gemini-2.5-pro" = {
                name = "Gemini 2.5 Pro (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "gemini-3-flash-preview" = {
                name = "Gemini 3 Flash Preview (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "gemini-3-pro-preview" = {
                name = "Gemini 3 Pro Preview (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65535;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
            };
          };
        };

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
            extensions = [ ".nix" ];
          };
        };
      };

      rules = "";

      agents = { };

      commands = {
        "dependabot-solver" = ../../ai/commands/dependabot-solver.md;
      };
    };
  };
}
