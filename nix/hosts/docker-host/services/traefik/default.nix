{
  config,
  pkgs,
  lib,
  ...
}: {
  services.traefik = {
    enable = true;

    staticConfigOptions = {
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
          http.tls = {};
      };

      log = {
        level = "DEBUG";
        filePath = "/var/lib/traefik/traefik.log";
        format = "json";
      };

      api.dashboard = true;
      api.insecure = true;
    };

    dynamicConfigOptions = {
      tls = {
        certificates = [
          {
            certFile = "/var/lib/acme/rger.dev/fullchain.pem";
            keyFile = "/var/lib/acme/rger.dev/key.pem";
          }
        ];
      };
      http = {
        routers = {
          argocd = {
            rule = "Host(`argocd.rger.dev`)";
            entryPoints = ["websecure"];
            service = "argocd";
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
