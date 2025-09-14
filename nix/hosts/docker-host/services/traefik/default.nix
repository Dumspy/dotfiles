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
        stores = {
          default = {
            defaultCertificate = {
              certFile = "/var/lib/acme/rger.dev/cert.pem";
              keyFile = "/var/lib/acme/rger.dev/key.pem";
            };
          };
        };
        certificates = [
          {
            certFile = "/var/lib/acme/rger.dev/cert.pem";
            keyFile = "/var/lib/acme/rger.dev/key.pem";
            stores = "default";
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
          proxmox = {
            rule = "Host(`proxmox.rger.dev`)";
            entryPoints = ["websecure"];
            service = "proxmox";
          };
        };
        services = {
          argocd = {
            loadBalancer.servers = [
              {url = "http://192.168.1.202:30080";}
            ];
          };
          proxmox = {
            loadBalancer.servers = [
              {url = "http://192.168.1.200:8006";}
            ];
          };
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [80 443 8080];
}
