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

      agents = {};

      commands = {
        "dependabot-solver" = ../../ai/commands/dependabot-solver.md;
      };
    };
  };
}
