{
  config,
  pkgs,
  lib,
  ...
}: {
  services.traefik = {
    enable = true;

    staticConfigOptions = {
        certificateResolvers.myresolver = {
        acme.certificates = [
            {
            certFile = "/var/lib/acme/rger.dev/cert.pem";
            keyFile = "/var/lib/acme/rger.dev/key.pem";
            domains = ["rger.dev" "*.rger.dev"];
            }
        ];
        };

      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
            permanent = true;
          };
        };
        websecure = {
          address = ":443";
        };
      };

      log = {
        level = "INFO";
        filePath = "/var/lib/traefik/traefik.log";
        format = "json";
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
            tls = {
              certResolver = "myresolver";
            };
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