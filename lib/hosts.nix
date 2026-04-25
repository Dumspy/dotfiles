{
  darwin = {
    type = "darwin";
    system = "aarch64-darwin";
  };
  wsl-devbox = {
    type = "nixos";
    system = "x86_64-linux";
    isWsl = true;
  };
  oci-node-1 = {
    type = "nixos";
    system = "aarch64-linux";
    ip = "100.99.30.112";
    deployUser = "deploy";
  };
  oci-node-2 = {
    type = "nixos";
    system = "aarch64-linux";
    ip = "100.120.122.114";
    deployUser = "deploy";
  };
  oci-node-3 = {
    type = "nixos";
    system = "aarch64-linux";
    ip = "100.64.54.67";
    deployUser = "deploy";
  };
  k3s-node = {
    type = "nixos";
    system = "x86_64-linux";
    ip = "100.109.48.72";
    deployUser = "deploy";
  };
  master-node = {
    type = "nixos";
    system = "x86_64-linux";
    ip = "100.83.126.36";
    deployUser = "deploy";
  };
}
