{...}: {
  imports = [
    ./hardware-configuration.nix
    ../oci-node/_common.nix
    ../oci-node/_agent.nix
  ];

  networking.hostName = "oci-node-2";

  myModules.system.k3s = {
    nodeIp = "10.0.1.68";
    extraFlags = ["--node-external-ip=10.0.1.68"];
  };
}
