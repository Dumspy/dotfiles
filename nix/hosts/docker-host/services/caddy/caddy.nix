{
  config,
  pkgs,
  lib,
  ...
}: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "felix.enok.berger@gmail.com";
    preliminarySelfsigned = false;

    certs."internal.rger.dev" = {
      group = config.services.caddy.group;

      domain = "internal.rger.dev";
      extraDomainNames = ["*.internal.rger.dev"];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      environmentFile = config.sops.secrets."cloudflare/.env".path;
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts = let
      sharedConfig = {
        useACMEHost = "internal.rger.dev";
      };
    in {
      router =
        sharedConfig
        // {
          name = "router.internal.rger.dev";
          value.extraConfig = ''
            reverse_proxy https://192.168.1.1
          '';
        };

      pve =
        sharedConfig
        // {
          name = "pve.internal.rger.dev";
          value.extraConfig = ''
            reverse_proxy https://192.168.1.200:8006
          '';
        };

      ha =
        sharedConfig
        // {
          name = "ha.internal.rger.dev";
          value.extraConfig = ''
            reverse_proxy http://192.168.1.201:8123
          '';
        };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
