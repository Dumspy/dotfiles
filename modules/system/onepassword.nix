{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.system.onepassword;
in {
  options.myModules.system.onepassword = {
    enable = lib.mkEnableOption "1Password secrets integration";
    secrets = lib.mkOption {
      type = with lib.types;
        attrsOf (submodule {
          options = {
            reference = lib.mkOption {
              type = types.str;
              description = "1Password reference path (e.g., op://vault/item/field)";
            };
            owner = lib.mkOption {
              type = types.str;
              default = "root";
              description = "Owner of the secret file";
            };
            group = lib.mkOption {
              type = types.str;
              default = "root";
              description = "Group of the secret file";
            };
            services = lib.mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Services that can read the secret";
            };
          };
        });
      default = {};
      description = "Secrets to fetch from 1Password vault";
    };
  };

  config = lib.mkIf cfg.enable {
    services.onepassword-secrets.enable = true;
    services.onepassword-secrets.tokenFile = "/etc/opnix-token";

    services.onepassword-secrets.secrets = lib.mkIf (cfg.secrets != {}) cfg.secrets;
  };
}
