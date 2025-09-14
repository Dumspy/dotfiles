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
      dnsResolver = "1.1.1.1:53";
      # dnsPropagationCheck=false;
      environmentFile = config.sops.secrets."cloudflare/.env".path;
      reloadServices = ["caddy.service"];
    };

    certs."rger.dev" = {
      domain = "rger.dev";
      extraDomainNames = ["*.rger.dev"];
      group = "certs";
    };
  };
}
