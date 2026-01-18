{
  config,
  lib,
  me,
  ...
}:
with lib; {
  options.myModules.system.openssh = {
    enable = mkEnableOption "OpenSSH server";
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Authorized public keys for SSH access";
    };
  };

  config = mkIf config.myModules.system.openssh.enable {
    services.openssh.enable = true;
    users.users."${config.var.username}".openssh.authorizedKeys.keys = config.myModules.system.openssh.authorizedKeys;
  };
}
