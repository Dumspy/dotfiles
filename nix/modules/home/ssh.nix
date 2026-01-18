{
  config,
  lib,
  ...
}:
with lib; {
  options.myModules.home.ssh = {
    enable = mkEnableOption "SSH client configuration";
    identityAgent = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SSH identity agent socket path";
    };
  };

  config = mkIf config.myModules.home.ssh.enable {
    programs.ssh = {
      enable = true;
      extraConfig = mkIf (config.myModules.home.ssh.identityAgent != null) ''
        Host *
          IdentityAgent "${config.myModules.home.ssh.identityAgent}"
      '';
    };
  };
}
