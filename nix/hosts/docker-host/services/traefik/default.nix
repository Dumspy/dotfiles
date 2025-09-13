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
          asDefault = true;
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
        level = "DEBUG";
        filePath = "/var/lib/traefik/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "admin@rger.dev";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = ["1.1.1.1:53" "8.8.8.8:53"];
          propagation = {
            disableChecks = true;
            delayBeforeChecks = 30;
          };
        };
      };

      api.dashboard = true;
      api.insecure = true;
    };

    dynamicConfigOptions = {
      http = {
        routers = {
            argocd = {
              rule = "Host(`argocd.rger.dev`)";
              entryPoints = ["websecure"];
              service = "argocd";
              tls.certResolver = "letsencrypt";
            };
        };
        services = {
          argocd = {
            loadBalancer.servers = [
              {url = "http://192.168.1.202:30080";}
            ];
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443 8080];
}
