{
  config,
  pkgs,
  lib,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."argocd.rger.dev".extraConfig = ''
      reverse_proxy http://192.168.1.202:30080
      tls /var/lib/acme/rger.dev/cert.pem /var/lib/acme/rger.dev/key.pem {
        protocols tls1.3
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
