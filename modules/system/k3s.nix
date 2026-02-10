{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.k3s;
  homePrefix = config.var.homePrefix;
in {
  options.myModules.system.k3s = {
    enable = lib.mkEnableOption "k3s Kubernetes distribution";

    role = lib.mkOption {
      type = lib.types.str;
      default = "server";
      description = "Role of the k3s node (server or agent)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = cfg.role;
    };

    networking.firewall.allowedTCPPorts = [6443];

    systemd.services.k3s.serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    systemd.services.setup-kubeconfig = {
      description = "Setup kubeconfig for user nixos";
      wantedBy = ["multi-user.target"];
      after = ["k3s.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "setup-kubeconfig" ''
          set -e

          echo "Starting kubeconfig setup..."

          # Wait for k3s.yaml to exist
          echo "Checking for k3s.yaml file..."
          while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
            echo "Waiting for k3s.yaml to exist..."
            sleep 1
          done
          echo "k3s.yaml file found, proceeding with setup."

          echo "Creating kubernetes config directory..."
          mkdir -p ${homePrefix}/.kube

          echo "Copying k3s.yaml to kubeconfig..."
          cp /etc/rancher/k3s/k3s.yaml ${homePrefix}/.kube/config

          echo "Setting proper ownership and permissions..."
          chown nixos:users ${homePrefix}/.kube/config
          chmod 600 ${homePrefix}/.kube/config

          echo "Kubeconfig setup completed successfully."
        '';
      };
    };
  };
}
