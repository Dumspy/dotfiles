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
      environmentFile = config.sops.secrets."cloudflare/.env".path;
    };

    certs."internal.rger.dev" = {
      domain = "internal.rger.dev";
      extraDomainNames = [
        "*.internal.rger.dev"
      ];
    };
  };

  systemd.services."acme-internal.rger.dev" = {
    before = ["caddy.service"];
  };

  services.caddy = {
    enable = true;
    logFormat = "level DEBUG";  # Enable detailed logging

    virtualHosts = let
      sharedConfig = {
        useACMEHost = "internal.rger.dev";
      };
    in {
      router =
        sharedConfig
        // {
          hostName = "router.internal.rger.dev";
          extraConfig = ''
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

  systemd.services.caddy = {
    requires = ["acme-internal.rger.dev.service"];
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
