{
  config,
  pkgs,
  inputs,
  ...
}: let
  opencode = inputs.opencode;
in {
  programs.opencode = {
    enable = true;
    package = opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      theme = "catppuccin-macchiato";
      autoupdate = false;

      # Security-focused tool permissions
      permission = {
        "read" = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.envrc" = "deny";
          "secrets/*" = "deny";
        };
      };
    };

    # Custom agents for specialized tasks
    agents = {
    };

    # Custom commands for common workflows
    commands = {
    };
  };
}
