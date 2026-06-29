{...}: {
  imports = [
    ./hardware-configuration.nix
    ../oci-node/_common.nix
    ../oci-node/_agent.nix
  ];

  networking.hostName = "oci-node-1";

  myModules.system.k3s = {
    nodeIp = "10.0.1.141";
    extraFlags = [
      "--node-external-ip=10.0.1.141"
      "--node-label=role=database"
    ];
  };
}
