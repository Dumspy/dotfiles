{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.supermemory;
in {
  options.myModules.system.supermemory = {
    enable = lib.mkEnableOption "Supermemory self-hosted memory server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 6767;
      description = "HTTP port for supermemory-server";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/supermemory";
      description = "Directory where supermemory stores its data";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../packages/supermemory {};
      description = "Supermemory server package";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Extra environment variables for the supermemory server";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to an environment file loaded by systemd (for secrets)";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the supermemory port";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.supermemory = {
      isSystemUser = true;
      group = "supermemory";
      home = cfg.dataDir;
      createHome = true;
      description = "Supermemory service user";
    };

    users.groups.supermemory = {};

    systemd.services.supermemory = {
      description = "Supermemory self-hosted memory server";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "simple";
        User = "supermemory";
        Group = "supermemory";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 5;

        WorkingDirectory = cfg.dataDir;
        StateDirectory = lib.optionalString (lib.hasPrefix "/var/lib/" cfg.dataDir) (lib.removePrefix "/var/lib/" cfg.dataDir);
        StateDirectoryMode = "0750";

        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [cfg.dataDir];
        PrivateTmp = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = false;
        SystemCallFilter = ["@system-service" "~@privileged"];
      };

      environment =
        {
          PORT = toString cfg.port;
          SUPERMEMORY_DATA_DIR = cfg.dataDir;
        }
        // cfg.environment;

      serviceConfig.EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
  };
}
