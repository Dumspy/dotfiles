{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.deploy;
in {
  options.myModules.system.deploy = {
    enable = lib.mkEnableOption "deploy user for deploy-rs";
  };

  config = lib.mkIf cfg.enable {
    users.users.deploy = {
      isNormalUser = true;
      description = "Deploy user for deploy-rs";
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [config.var.publicKey];
    };

    security.sudo.extraRules = [
      {
        users = ["deploy"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    services.openssh.extraConfig = ''
      Match User deploy
        PasswordAuthentication no
    '';
  };
}
