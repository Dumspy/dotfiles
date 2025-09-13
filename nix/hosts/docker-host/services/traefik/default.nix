{
  config,
  pkgs,
  lib,
  ...
}: {
  services.traefik = {
    enable = true;
    environmentFiles = [config.sops.secrets."cloudflare/.env".path];

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          http = {
            tls = {
                certResolver = "letsencrypt";
              };
            };
          };
      };

      log = {
        level = "INFO";
        filePath = "/var/lib/traefik/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "admin@rger.dev";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = ["1.1.1.1:53" "1.0.0.1:53"];
          delayBeforeChecks = 60;
          disableChecks = true;
        };
      };

      api.dashboard = true;
      api.debug = true;
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          dashboard = {
            rule = "Host(`internal.rger.dev`)";
            service = "api@internal"; # Special service name for the dashboard
            entryPoints = ["websecure"];
          };
        };
      };
    };
  };
}
