{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.claude-code;
in {
  options.myModules.home.claude-code = {
    enable = lib.mkEnableOption "Claude Code, Anthropic's official CLI";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;

      settings = {
        includeCoAuthoredBy = false;

        permissions = {
          allow = [
            "Read"
            "Bash(ls:*)"
            "Bash(pwd:*)"
            "Bash(git status:*)"
            "Bash(git diff:*)"
            "Bash(git log:*)"
            "Bash(dex:*)"
          ];
          ask = [
            "Bash"
            "WebFetch"
          ];
          deny = [
            # Secrets & credentials
            "Read(./.direnv/**)"
            "Read(./.env)"
            "Read(./*.env)"
            "Read(./*.env.*)"
            "Read(./*.envrc)"
            "Read(./secrets/**)"
            # Private keys & auth
            "Read(./.ssh/**)"
            "Read(./.gnupg/**)"
            "Read(./.config/1password/**)"
            "Read(./*.key)"
            "Read(./*.pem)"
            "Read(./*.p12)"
            "Read(./*.pfx)"
            # Cloud/container credentials
            "Read(./.aws/**)"
            "Read(./.docker/**)"
            "Read(./.kube/**)"
            # Version control internals
            "Read(./.git/**)"
            "Read(./.gitmodules)"
            # Build artifacts (large, noisy)
            "Read(./node_modules/**)"
            "Read(./.venv/**)"
            "Read(./venv/**)"
            "Read(./dist/**)"
            "Read(./build/**)"
            "Read(./target/**)"
          ];
        };
      };
    };
  };
}
