{
  config,
  pkgs,
  lib,
  ...
}: {
  security.acme = {
    acceptTerms = true;
    preliminarySelfsigned = false;

    defaults = {
      email = "felix.enok.berger@gmail.com";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.secrets."cloudflare/.env".path;
      reloadServices = ["caddy.service"];
    };

    certs."internal.rger.dev" = {
      domain = "internal.rger.dev";
      extraDomainNames = [
        "*.internal.rger.dev"
      ];
      group = config.services.caddy.group;
    };
  };

  services.caddy = {
    enable = true;
    logFormat = "level DEBUG"; # Enable detailed logging

    virtualHosts = let
      sharedConfig = {
        useACMEHost = "internal.rger.dev";
        extraConfig = ''
          tls {
            load_files /var/lib/acme/internal.rger.dev/fullchain.pem /var/lib/acme/internal.rger.dev/key.pem
          }
        '';
      };
    in {
      router =
        sharedConfig
        // {
          hostName = "router.internal.rger.dev";
            reverse_proxy https://192.168.1.1
          '';
        };

      pve =
        sharedConfig
        // {
          hostName = "pve.internal.rger.dev";
          extraConfig = ''
            reverse_proxy https://192.168.1.200:8006
          '';
        };

      ha =
        sharedConfig
        // {
          hostName = "ha.internal.rger.dev";
          extraConfig = ''
            reverse_proxy http://192.168.1.201:8123
          '';
        };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
