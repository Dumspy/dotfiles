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
    virtualHosts = builtins.listToAttrs [
      (mkVirtualHost {
        name = "router";
        target = "192.168.1.1";
      })

      (mkVirtualHost {
        name = "pve";
        target = "192.168.1.200:8006";
      })
    ];
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
