{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.system.onepassword;
in {
  options.myModules.system.onepassword = {
    enable = lib.mkEnableOption "1Password secrets integration";
  };

  config = lib.mkIf cfg.enable {
    services.onepassword-secrets = {
      enable = true;
      tokenFile = "/etc/opnix-token";

      secrets = {
        pocPassword = {
          reference = "op://NixSecrets/POC/password";
        };
      };
    };
  };
}
