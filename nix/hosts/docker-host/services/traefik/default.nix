{
  config,
  pkgs,
  lib,
  ...
}: {
  services.traefik = {
    enable = true;
    environmentFiles = [ "/run/secrets/traefik.env" ];

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
        httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
    };

    dynamicConfigOptions = {
      http.routers = {};
      http.services = {};
    };
  };
}
