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
      extraLegoFlags = [
        "--dns.resolvers=1.1.1.1:53,8.8.8.8:53"
      ];
    };

    certs."internal.rger.dev" = {
      domain = "internal.rger.dev";
      extraDomainNames = ["*.internal.rger.dev"];
      group = "certs";
    };
  };
}
