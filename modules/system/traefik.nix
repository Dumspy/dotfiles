{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.traefik;
in {
  options.myModules.system.traefik = {
    enable = lib.mkEnableOption "Traefik reverse proxy";
  };

  config = lib.mkIf cfg.enable {
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

      environmentFiles = [
        config.services.onepassword-secrets.secretPaths.cloudflareEnv
        (pkgs.writeText "traefik-lego-env" ''
          LEGO_DISABLE_CNAME_SUPPORT=true
        '')
      ];

      staticConfigOptions = {
        api = {
          dashboard = true;
          insecure = true;
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
            asDefault = true;
            http.tls = {
              certResolver = "letsencrypt";
              domains = [
                {
                  main = "*.internal.rger.dev";
                }
              ];
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
            resolvers = [
              "1.1.1.1:53"
              "1.0.0.1:53"
            ];
            propagation = {
              disableChecks = true;
              delayBeforeChecks = 20;
            };
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
            };

            argocd = {
              rule = "Host(`argocd.internal.rger.dev`)";
              service = "argocd-service";
              entryPoints = ["websecure"];
            };

            grafana = {
              rule = "Host(`grafana.internal.rger.dev`)";
              service = "grafana-service";
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

            grafana-service = {
              loadBalancer = {
                servers = [
                  {url = "http://127.0.0.1:2342";}
                ];
              };
            };
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
