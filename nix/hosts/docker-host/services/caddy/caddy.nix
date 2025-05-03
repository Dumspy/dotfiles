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
      group = "acme";
      domain = "*.internal.rger.dev";
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      environmentFile = config.sops.secrets."cloudflare/.env".path;
    };
  };

  systemd.services."acme-internal.rger.dev" = {
    before = ["caddy.service"];
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https disable_certs
    '';

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
    after = ["acme-internal.rger.dev.service"];
    wantedBy = [ "multi-user.target" ];
  };

  users.users.caddy.extraGroups = [ "acme" ];

  networking.firewall.allowedTCPPorts = [80 443];
}
