{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.kubeconfig;
in {
  options.myModules.system.kubeconfig = {
    enable = lib.mkEnableOption "kubeconfig management for multiple Kubernetes clusters";
    user = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Default user to own the kubeconfig files";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Default group for the kubeconfig files";
    };
    clusters = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          reference = lib.mkOption {
            type = lib.types.str;
            description = "1Password reference path (e.g., op://vault/item/field)";
          };
          contextName = lib.mkOption {
            type = lib.types.str;
            description = "Kubernetes context name";
          };
          alias = lib.mkOption {
            type = lib.types.str;
            description = "Shell alias name (e.g., K3S, OCI)";
          };
          user = lib.mkOption {
            type = lib.types.str;
            default = cfg.user;
            description = "Owner of the kubeconfig file";
          };
          group = lib.mkOption {
            type = lib.types.str;
            default = cfg.group;
            description = "Group of the kubeconfig file";
          };
        };
      });
      default = {};
      description = "Map of cluster names to their 1Password kubeconfig references";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.clusters != {}) {
    myModules.system.onepassword.enable = true;

    services.onepassword-secrets.secrets =
      lib.mapAttrs (name: clusterCfg: {
        reference = clusterCfg.reference;
        owner = clusterCfg.user;
        group = clusterCfg.group;
      })
      cfg.clusters;

    environment.variables = {
      KUBECONFIG = lib.concatStringsSep ":" (lib.mapAttrsToList (name: _: config.services.onepassword-secrets.secretPaths.${name}) cfg.clusters);
    };

    home-manager.sharedModules = [
      {
        _module.args.kubeconfigClusters = cfg.clusters;
      }
    ];
  };
}
