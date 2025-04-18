{
  config,
  pkgs,
  lib,
  ...
}: let
  certloc = "/var/lib/acme/internal.rger.dev";
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = "felix.enok.berger@gmail.com";

    certs."internal.rger.dev" = {
      group = config.services.caddy.group;

      domain = "internal.rger.dev";
      extraDomainNames = ["*.internal.rger.dev"];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.secrets."cloudflare/.env".path;
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts."router.internal.rger.dev".extraConfig = ''
      reverse_proxy http://192.168.1.1

      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';

    virtualHosts."pve.internal.rger.dev".extraConfig = ''
      reverse_proxy http://192.168.1.200:8006

      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';

    virtualHosts."ha.internal.rger.dev".extraConfig = ''
      reverse_proxy http://192.168.1.201:8123

      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
