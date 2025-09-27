{
  config,
  pkgs,
  lib,
  ...
}: {
  services.onepassword-secrets.secrets = {
    cloudflareEnv = {
      reference = "op://NixSecrets/orthjfp4m5gvfp5vcnbhmjdxcy/env_version";
      owner = "traefik";
      group = "traefik";
      services = ["traefik"];
    };
  };

  services.traefik = {
    enable = true;

    environmentFiles = [config.services.onepassword-secrets.secretPaths.cloudflareEnv];

    staticConfigOptions = {
      api = {
        dashboard = true;
        insecure = false;
      };

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
          asDefault = true;
          tls.dominas = [
            {
              main = "internal.rger.dev";
              sans = ["*.internal.rger.dev"];
            }
          ];
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
          delayBeforeCheck = 15;
        };
      };
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          dashboard = {
            rule = "Host(`traefik.internal.rger.dev`)";
            service = "api@internal";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
            };
          };

          argocd = {
            rule = "Host(`argocd.internal.rger.dev`)";
            service = "argocd-service";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
            };
          };
        };

        services = {
          argocd-service = {
            loadBalancer = {
              servers = [
                {url = "http://192.168.1.202:30080";}
              ];
            };
          };
        };
      };
    };
  };
}
