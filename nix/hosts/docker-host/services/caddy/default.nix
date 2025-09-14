{
  config,
  pkgs,
  lib,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."pve.rger.dev".extraConfig = ''
      reverse_proxy http://192.168.1.200:8006/
      tls /var/lib/acme/rger.dev/cert.pem /var/lib/acme/rger.dev/key.pem {
        protocols tls1.3
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
