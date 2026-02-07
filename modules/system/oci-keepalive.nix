{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.oci-keepalive;
in {
  options.myModules.system.oci-keepalive = {
    enable = lib.mkEnableOption "Enable OCI keep-alive service";
    activeHours = lib.mkOption {
      type = lib.types.str;
      description = "Active hours HH-HH (UTC)";
      default = "06-22";
    };
    minLoad = lib.mkOption {
      type = lib.types.int;
      description = "Min CPU load %";
      default = 5;
    };
    maxLoad = lib.mkOption {
      type = lib.types.int;
      description = "Max CPU load %";
      default = 30;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.oci-keepalive = {
      description = "OCI Always Free Reclamation Prevention";
      wantedBy = ["multi-user.target"];
      after = ["tailscaled.service"];
      path = with pkgs; [bash coreutils];
      script = ''
        ACTIVE_HOURS="${cfg.activeHours}"
        ACTIVE_START=''${ACTIVE_HOURS%-*}
        ACTIVE_END=''${ACTIVE_HOURS#*-}
        CURRENT_HOUR=$(date +%H)
        if [ "$CURRENT_HOUR" -ge "$ACTIVE_START" ] && [ "$CURRENT_HOUR" -lt "$ACTIVE_END" ]; then
          MIN_LOAD="${toString cfg.minLoad}"
          MAX_LOAD="${toString cfg.maxLoad}"
          LOAD_FACTOR=$((RANDOM % (MAX_LOAD - MIN_LOAD + 1) + MIN_LOAD))
        else
          LOAD_FACTOR=$((RANDOM % 11 + 5))
        fi
        DURATION=$((LOAD_FACTOR * 2))
        dd if=/dev/urandom of=/tmp/keepalive bs=1M count=$LOAD_FACTOR 2>/dev/null
        rm -f /tmp/keepalive
        MEM_USAGE=$((LOAD_FACTOR * 10))
        dd if=/dev/urandom of=/tmp/memload bs=1M count=$MEM_USAGE 2>/dev/null
        rm -f /tmp/memload
        SLEEP_TIME=$((RANDOM % 480 + 120))
        sleep $SLEEP_TIME
      '';
      Restart = "always";
      RestartSec = "30s";
    };
  };
}
