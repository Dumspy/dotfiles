{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.ssh;
in {
  options.myModules.home.ssh = {
    enable = lib.mkEnableOption "SSH client configuration";
    identityAgent = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SSH identity agent socket path";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      # Use 1Password agent only for local sessions. When logged in over SSH
      # ($SSH_CONNECTION is set), fall back to $SSH_AUTH_SOCK so agent
      # forwarding from the original client keeps working instead of being
      # overridden by IdentityAgent (which takes precedence over the
      # forwarded socket and would trigger a local Touch ID prompt).
      extraConfig = lib.mkIf (cfg.identityAgent != null) ''
        Match host * exec "test -z \"$SSH_CONNECTION\""
          IdentityAgent "${cfg.identityAgent}"
      '';
    };
  };
}
