{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}: let
  cfg = config.myModules.system.tailscale;
in {
  options.myModules.system.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
    exitNode = lib.mkEnableOption "Advertise as exit node";
  };

  config = lib.mkMerge (
    [
      (lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.tailscale];
        services.tailscale.enable = true;
      })
    ]
    ++ lib.optionals (!isDarwin) [
      (lib.mkIf (cfg.enable && cfg.exitNode) {
        networking.firewall.checkReversePath = false;

        boot.kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };
        services.tailscale.openFirewall = true;
        services.tailscale.useRoutingFeatures = "server";

        systemd.services.tailscale-udp-gro = {
          description = "Configure UDP GRO for Tailscale performance";
          wantedBy = ["multi-user.target"];
          after = ["network.target"];
          path = [
            pkgs.ethtool
            pkgs.iproute2
          ];
          script = ''
            NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
            ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
          '';
        };
      })
    ]
  );
}
