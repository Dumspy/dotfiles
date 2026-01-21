{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.myModules.home.opencode;
  opencode = inputs.opencode;
in {
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

        model = "zai-coding-plan/glm-4.7";

        plugin = [];

        mcp = {
          grep_app = {
            type = "remote";
            url = "https://mcp.grep.app";
            enabled = false;
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
    };
  };
}
