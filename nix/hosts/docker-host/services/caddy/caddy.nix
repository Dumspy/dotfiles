{
  config,
  pkgs,
  lib,
  ...
}: let
  certloc = "/var/lib/acme/internal.rger.dev";

  # Helper function for creating virtual hosts with similar configs
  mkVirtualHost = {
    name,
    target,
    isHttps ? false,
  }: {
    name = "${name}.internal.rger.dev";
    value.extraConfig = ''
      reverse_proxy ${
        if isHttps
        then "https"
        else "http"
      }://${target} ${
        if isHttps
        then ''
          {
            transport http {
              tls_insecure_skip_verify
            }
          }
        ''
        else ""
      }

      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = "felix.enok.berger@gmail.com";

    certs."internal.rger.dev" = {
      group = config.services.caddy.group;
      systemd.before = ["caddy.service"];

      domain = "internal.rger.dev";
      extraDomainNames = ["*.internal.rger.dev"];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      environmentFile = config.sops.secrets."cloudflare/.env".path;
      preliminarySelfsigned = false;  # Disable self-signed certificate
    };
  };

  services.caddy = {
    enable = true;

    systemd.services.caddy.after = ["acme-internal.rger.dev.service"];

    virtualHosts = builtins.listToAttrs [
      (mkVirtualHost {
        name = "router";
        target = "192.168.1.1";
        isHttps = true;
      })
      (mkVirtualHost {
        name = "pve";
        target = "192.168.1.200:8006";
        isHttps = true;
      })
      (mkVirtualHost {
        name = "ha";
        target = "192.168.1.201:8123";
        isHttps = false;
      })
    ];
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
