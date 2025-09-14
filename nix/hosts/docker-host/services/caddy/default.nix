{
  config,
  pkgs,
  lib,
  ...
}: let
  certloc = "/var/lib/acme/rger.dev";
  mkVirtualHost = {
    name,
    target,
  }: {
    name = "${name}.rger.dev";
    value.extraConfig = ''
      reverse_proxy https://${target} {
        transport http {
          tls_insecure_skip_verify
        }
      }
      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };
in {
  services.caddy = {
    enable = true;
    virtualHosts."router.rger.dev".extraConfig = ''
      reverse_proxy http://192.168.1.1
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
