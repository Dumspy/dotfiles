{
  config,
  pkgs,
  lib,
  me,
  ...
}: {
  services.k3s = {
    enable = true;
    role = "server";
  };

  networking.firewall.allowedTCPPorts = [6443];

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
        mkdir -p ${me.homePrefix}/.kube

        echo "Copying k3s.yaml to kubeconfig..."
        cp /etc/rancher/k3s/k3s.yaml ${me.homePrefix}/.kube/config

        echo "Setting proper ownership and permissions..."
        chown nixos:users ${me.homePrefix}/.kube/config
        chmod 600 ${me.homePrefix}/.kube/config

        echo "Kubeconfig setup completed successfully."
      '';
    };
  };
}
