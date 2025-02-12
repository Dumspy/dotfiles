{
  config,
  pkgs,
  lib,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."ha.local".extraConfig = ''
      reverse_proxy http://192.168.1.201:8123
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
