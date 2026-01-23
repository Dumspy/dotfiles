{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.system.openssh;
in {
  options.myModules.system.openssh = {
    enable = lib.mkEnableOption "OpenSSH server";
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Authorized public keys for SSH access";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    users.users."${config.var.username}".openssh.authorizedKeys.keys = cfg.authorizedKeys;
  };
}
