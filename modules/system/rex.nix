{
  config,
  lib,
  pkgs,
  inputs,
  hostName,
  ...
}: let
  cfg = config.myModules.system.rex;
in {
  imports = [
    inputs.rex.nixosModules.default
  ];

  options.myModules.system.rex = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run Rex's shared server (`rex.service`, account `rex`) and join the
        tailnet with Rex's built-in Tailscale as `rex-<hostname>`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    myModules.system.onepassword.enable = true;

    # Root-only. services = ["rex"] starts rex.service after opnix writes this.
    services.onepassword-secrets.secrets.rexAuthKey = {
      reference = "op://Shared-Secret/rex-authkey/password";
      owner = "root";
      group = "root";
      mode = "0400";
      services = ["rex"];
    };

    # The module creates the rex system user and does not set a shell. nologin
    # makes every shared-server terminal exit immediately.
    users.users.rex.shell = pkgs.bashInteractive;

    services.rex = {
      enable = true;
      tailscale = {
        enable = true;
        hostname = "rex-${hostName}";
        advertiseTags = ["tag:rex"];
        authKeyFile = config.services.onepassword-secrets.secretPaths.rexAuthKey;
        # --tailscale-allow-tailnet-members. A tagged device has no owner.
        allowTailnetMembers = true;
      };
    };
  };
}
