{
  config,
  pkgs,
  lib,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."router.rger.dev".extraConfig = ''
      reverse_proxy https://192.168.1.1 {
        transport http {
          tls_insecure_skip_verify
        }
      }
      tls /var/lib/acme/rger.dev/cert.pem /var/lib/acme/rger.dev/key.pem {
        protocols tls1.3
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
