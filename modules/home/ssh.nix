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
      extraConfig = lib.mkIf (cfg.identityAgent != null) ''
        Host *
          IdentityAgent "${cfg.identityAgent}"
      '';
    };
  };
}
