{
  config,
  pkgs,
  lib,
  ...
}: {
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "felix.enok.berger@gmail.com";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."cloudflare/.env".path;
      reloadServices = ["caddy.service"];
      extraLegoFlags = [
        "--dns.resolvers=1.1.1.1:53,8.8.8.8:53,9.9.9.9:53"
      ];
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

  networking.firewall.allowedTCPPorts = [80 443];
}
