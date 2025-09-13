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
        level = "INFO";
        filePath = "/var/lib/traefik/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "admin@rger.dev";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          propagation = {
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
            service = "argocd-server";
            tls.certResolver = "letsencrypt";
          };
        };
      };

      services = {
        argocd-server = {
          loadBalancer.servers = [
            {url = "http://192.168.1.202:30080";}
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443 8080];
}
