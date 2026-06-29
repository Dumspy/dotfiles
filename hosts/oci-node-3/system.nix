{...}: {
  imports = [
    ./hardware-configuration.nix
    ../oci-node/_common.nix
  ];

  networking.hostName = "oci-node-3";

  myModules.system = {
    tailscale.exitNode = true;
    k3s = {
      role = "server";
      nodeIp = "10.0.1.215";
      extraFlags = [
        "--tls-san=10.0.1.215"
        "--tls-san=100.64.54.67"
        "--disable=traefik"
        "--write-kubeconfig-mode 0644"
      ];
    };
  };

  # Extra firewall ports for the server node (tinyproxy + k3s API)
  networking.firewall.allowedTCPPorts = [8888 6443];

  # Tinyproxy serving oci-node-1 and oci-node-2
  services.tinyproxy = {
    enable = true;
    settings = {
      Listen = "0.0.0.0";
      Port = 8888;
      Allow = ["10.0.1.0/24"];
    };
  };

  # Prevent tinyproxy from restarting during rebuilds
  # to maintain network connectivity for oci-node-1 and oci-node-2
  systemd.services.tinyproxy.restartIfChanged = false;
}
