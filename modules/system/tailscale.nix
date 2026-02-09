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
  };
}
