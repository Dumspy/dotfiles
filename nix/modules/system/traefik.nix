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
          delayBeforeCheck = 15;
        };
        domains = [
          { main = "internal.rger.dev"; sans = ["*.internal.rger.dev"]; }
        ];
      };
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          dashboard = {
            rule = "Host(`traefik.internal.rger.dev`)";
            service = "api@internal";
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
                {url = "http://192.168.1.202:30080";}
              ];
            };
          };
        };
      };
    };
  };
}
