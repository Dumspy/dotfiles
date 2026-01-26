{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.myModules.home.opencode;
  portable = config.myModules.home.portable or false;

  opensrc-mcp =
    if !portable
    then
      pkgs.buildNpmPackage {
        pname = "opensrc-mcp";
        version = "0.3.0";

        src = pkgs.fetchFromGitHub {
          owner = "dmmulroy";
          repo = "opensrc-mcp";
          rev = "v0.3.0";
          hash = "sha256-g9fAW8jCKPcNVujsn1bDxJtc2lJmr0Vv6ANcL/Uwr1s=";
        };

        npmDepsHash = "sha256-nFds8MSZld/mV8bqeCRDvP2i1+FMnRxLapHJafeW/ew=";

        nodejs = pkgs.nodejs_22;

        meta = {
          description = "MCP server for fetching and querying dependency source code";
          license = lib.licenses.mit;
          mainProgram = "opensrc-mcp";
        };
      }
    else null;
in {
  options.myModules.home.opencode = {
    enable = lib.mkEnableOption "opencode AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;

      settings = {
        autoupdate = false;

        model = "zai-coding-plan/glm-4.7";

        mcp = {
          grep_app = {
            type = "remote";
            url = "https://mcp.grep.app";
          };
          opensrc = {
            type = "local";
            command =
              if portable
              then ["npx" "opensrc-mcp"]
              else ["${opensrc-mcp}/bin/opensrc-mcp"];
          };
        };

        provider = {};

        permission = {
          "read" = {
            "*" = "allow";
            # Secrets & credentials
            ".direnv/*" = "deny";
            ".env" = "deny";
            "*.env" = "deny";
            "*.env.*" = "deny";
            "*.envrc" = "deny";
            "secrets/*" = "deny";
            # Private keys & auth
            ".ssh/*" = "deny";
            ".gnupg/*" = "deny";
            ".config/1password/*" = "deny";
            "*.key" = "deny";
            "*.pem" = "deny";
            "*.p12" = "deny";
            "*.pfx" = "deny";
            # Cloud/container credentials
            ".aws/*" = "deny";
            ".docker/*" = "deny";
            ".kube/*" = "deny";
            # Version control internals
            ".git/*" = "deny";
            ".gitmodules" = "deny";
            # Build artifacts (large, noisy)
            "node_modules/*" = "deny";
            ".venv/*" = "deny";
            "venv/*" = "deny";
            "dist/*" = "deny";
            "build/*" = "deny";
            "target/*" = "deny";
          };
          webfetch = "ask";
          bash = {
            "*" = "ask";
            "ls*" = "allow";
            "pwd" = "allow";
            "git status*" = "allow";
            "git diff*" = "allow";
            "git log*" = "allow";
            "dex *" = "allow";
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

      commands = {
        "dependabot-solver" = ../../ai/commands/dependabot-solver.md;
      };

      agents = {
        librarian = ../../ai/agents/librarian.md;
        oracle = ../../ai/agents/oracle.md;
      };
    };
  };
}
