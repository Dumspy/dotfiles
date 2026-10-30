{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.system.nix-netrc;
  netrcPath = "/etc/nix/netrc";
in {
  options.myModules.system.nix-netrc = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Fetch the shared Nix netrc from 1Password (`op://Shared-Secret/rex-netrc/netrc`)
        and point Nix at it. The item value is the full netrc line.

        `/etc/opnix-token` must already exist on the host before deploying.
        This does not install Rex.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    myModules.system.onepassword.enable = true;

    services.onepassword-secrets.secrets.nixNetrc = {
      reference = "op://Shared-Secret/rex-netrc/netrc";
      path = netrcPath;
      owner = "root";
      group = "root";
      mode = "0600";
    };

    # The daemon default is already $NIX_CONF_DIR/netrc. NixOS and nix-darwin
    # (`nix.enable`) both use /etc/nix. Pin it so nix.conf does not depend on
    # NIX_CONF_DIR.
    nix.settings.netrc-file = config.services.onepassword-secrets.secretPaths.nixNetrc;
  };
}
