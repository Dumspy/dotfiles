{
  config,
  pkgs,
  lib,
  ...
}: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "felix.enok.berger@gmail.com";

    certs."internal.rger.dev" = {
      group = "certs";
      domain = "internal.rger.dev";
      extraDomainNames = ["*.internal.rger.dev"];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      environmentFile = config.sops.secrets."cloudflare/.env".path;
    };
  };
}