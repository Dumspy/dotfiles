{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.onepassword-agent;
in {
  options.myModules.system.onepassword-agent = {
    enable = lib.mkEnableOption "1Password SSH agent relay for WSL";
  };

  config = lib.mkIf cfg.enable {
    systemd.services."1password-agent" = {
      description = "1Password SSH Agent Relay";
      wantedBy = ["multi-user.target"];
      path = [pkgs.socat];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.bash}/bin/bash -c " \
            rm -f /run/1password-agent.sock; \
            exec ${pkgs.socat}/bin/socat \
              UNIX-LISTEN:/run/1password-agent.sock,fork,mode=0666 \
              EXEC:'/mnt/c/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent',nofork \
          "
        '';
        Restart = "always";
        RestartSec = 5;
        User = "root";
        RuntimeDirectory = "1password-agent";
        RuntimeDirectoryMode = "0755";
      };
    };

    environment.variables = {
      SSH_AUTH_SOCK = "/run/1password-agent.sock";
    };
  };
}
