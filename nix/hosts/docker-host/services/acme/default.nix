{
  config,
  pkgs,
  lib,
  ...
}: {
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "admin@rger.dev";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."cloudflare/.env".path;
      extraLegoFlags = [
        "--dns.resolvers=1.1.1.1:53,8.8.8.8:53"
      ];
    };

    certs."rger.dev" = {
      domain = "rger.dev";
      extraDomainNames = ["*.rger.dev"];
      group = "certs";
    };
  };
}
