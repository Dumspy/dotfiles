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

    serverAddr = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Server URL for agents (e.g., https://10.0.1.215:6443)";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to k3s cluster token file";
    };

    nodeIp = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Node IP address for k3s";
    };

    flannelIface = lib.mkOption {
      type = lib.types.str;
      default = "enp0s6";
      description = "Network interface for Flannel CNI";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional k3s CLI flags";
    };
  };

  config = lib.mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = cfg.role;
      serverAddr = lib.mkIf (cfg.role == "agent" && cfg.serverAddr != null) cfg.serverAddr;
      tokenFile = lib.mkIf (cfg.role == "agent" && cfg.tokenFile != null) cfg.tokenFile;
      extraFlags = lib.lists.flatten [
        (lib.optional (cfg.nodeIp != null) "--node-ip=${cfg.nodeIp}")
        (lib.optional (cfg.nodeIp != null) "--node-external-ip=${cfg.nodeIp}")
        (lib.optional (cfg.flannelIface != "") "--flannel-iface=${cfg.flannelIface}")
        cfg.extraFlags
      ];
    };

    networking.firewall.allowedTCPPorts = lib.lists.flatten [
      (lib.optional (cfg.role == "server") 6443)
      (lib.optional true 8472)
    ];
    networking.firewall.allowedUDPPorts = [8472];

    systemd.services.k3s.after = lib.mkIf (cfg.role == "agent") ["opnix-secrets.service"];
    systemd.services.k3s.wants = lib.mkIf (cfg.role == "agent") ["opnix-secrets.service"];

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
