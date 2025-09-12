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
          # The default certResolver for any router on this entrypoint
          http.tls.certResolver = "letsencrypt";
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
          delayBeforeCheck = 30;
        };
        domains = [
          {
            main = "internal.rger.dev";
            sans = ["*.internal.rger.dev"];
          }
        ];
      };

      # The dashboard itself is enabled here.
      api.dashboard = true;
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          dashboard = {
            rule = "Host(`traefik.internal.rger.dev`)";
            service = "api@internal"; # Special service name for the dashboard
            entryPoints = ["websecure"];
          };

          argocd = {
            rule = "Host(`argocd.internal.rger.dev`)";
            service = "argocd-service";
            entryPoints = ["websecure"];
          };
        };

        services = {
          argocd-service = {
            loadBalancer = {
              servers = [
                {url = "http://192.168.1.200:30080";}
              ];
            };
          };
        };
      };
    };
  };
}
