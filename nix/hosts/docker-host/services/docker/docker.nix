{
  config,
  pkgs,
  lib,
  ...
}: {
  users.users.nixos.extraGroups = ["docker"];

  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # hello-world = import ./containers/hello-world.nix {inherit config pkgs;};
      # nginx-proxy-manager = import ./containers/nginx-proxy-manager.nix {inherit config pkgs;};
    };
  };
}
