# Single source of truth for all hosts in this flake.
#
# Each host records everything the flake + deploy-rs need to build and deploy it:
#   type          "darwin" | "nixos"
#   system        nixpkgs host platform
#   username      primary user (passed as specialArgs.username)
#   withHomeManager  (nixos only) enable home-manager for this host
#   isWsl         (nixos only) WSL host flag
#   ip            tailscale IP; presence marks the host as deploy-rs target
#   deployUser    ssh user for deploy-rs
#   extraModules  function `inputs: [ ... ]` of host-specific modules beyond
#                 the per-type defaults (opnix.nixos/darwinModules.default added
#                 by the generators in lib/default.nix)
{
  darwin = {
    type = "darwin";
    system = "aarch64-darwin";
    username = "felix.berger";
    extraModules = _: [];
  };

  wsl-devbox = {
    type = "nixos";
    system = "x86_64-linux";
    username = "nixos";
    isWsl = true;
    withHomeManager = true;
    extraModules = inputs: [inputs.nixos-wsl.nixosModules.default];
  };

  k3s-node = {
    type = "nixos";
    system = "x86_64-linux";
    username = "nixos";
    withHomeManager = false;
    ip = "100.109.48.72";
    deployUser = "deploy";
    extraModules = _: [];
  };

  master-node = {
    type = "nixos";
    system = "x86_64-linux";
    username = "nixos";
    withHomeManager = false;
    ip = "100.83.126.36";
    deployUser = "deploy";
    extraModules = _: [];
  };

  oci-node-1 = {
    type = "nixos";
    system = "aarch64-linux";
    username = "nixos";
    withHomeManager = false;
    ip = "100.99.30.112";
    deployUser = "deploy";
    extraModules = _: [];
  };

  oci-node-2 = {
    type = "nixos";
    system = "aarch64-linux";
    username = "nixos";
    withHomeManager = false;
    ip = "100.120.122.114";
    deployUser = "deploy";
    extraModules = _: [];
  };

  oci-node-3 = {
    type = "nixos";
    system = "aarch64-linux";
    username = "nixos";
    withHomeManager = false;
    ip = "100.64.54.67";
    deployUser = "deploy";
    extraModules = _: [];
  };
}
