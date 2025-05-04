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

    certs."rger.dev" = {
      domain = "rger.dev";
      extraDomainNames = [
        "*.rger.dev"
        "*.internal.rger.dev"
      ];
    };
  };

  systemd.services."acme-rger.dev" = {
    before = ["caddy.service"];
  };

  services.caddy = {
    enable = true;
    logFormat = "json";  # Enable detailed logging
    globalConfig = ''
      debug
    '';

    virtualHosts = let
      sharedConfig = {
        useACMEHost = "rger.dev";
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
    requires = ["acme-rger.dev.service"];
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
