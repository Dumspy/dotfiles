{
  self,
  deploy-rs,
}: {
  oci-node-1 = {
    hostname = "100.99.30.112";
    sshUser = "deploy";
    user = "root";
    profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.oci-node-1;
    magicRollback = true;
    remoteBuild = true;
  };

  oci-node-2 = {
    hostname = "100.120.122.114";
    sshUser = "deploy";
    user = "root";
    profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.oci-node-2;
    magicRollback = true;
    remoteBuild = true;
  };

  oci-node-3 = {
    hostname = "100.64.54.67";
    sshUser = "deploy";
    user = "root";
    profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.oci-node-3;
    magicRollback = true;
    remoteBuild = true;
  };

  k3s-node = {
    hostname = "100.109.48.72";
    sshUser = "deploy";
    user = "root";
    profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.k3s-node;
    magicRollback = true;
    remoteBuild = true;
  };

  master-node = {
    hostname = "100.83.126.36";
    sshUser = "deploy";
    user = "root";
    profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.master-node;
    magicRollback = true;
    remoteBuild = true;
  };
}
