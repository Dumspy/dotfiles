{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.tailscale;
in {
  options.myModules.system.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
    exitNode = lib.mkEnableOption "Advertise as exit node";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.tailscale];
    services.tailscale.enable = true;

    networking.firewall.checkReversePath = false;

    boot.kernel.sysctl = lib.mkIf cfg.exitNode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    services.tailscale.openFirewall = lib.mkIf cfg.exitNode true;
    services.tailscale.useRoutingFeatures = lib.mkIf cfg.exitNode "server";

    systemd.services.tailscale-udp-gro = lib.mkIf cfg.exitNode {
      description = "Configure UDP GRO for Tailscale performance";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      path = [pkgs.ethtool pkgs.iproute2];
      script = ''
        NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
        ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };
}
