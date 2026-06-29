{
  nixpkgs,
  nix-darwin,
  home-manager,
  catppuccin,
  inputs,
  flakeRoot ? ./..,
  ...
}: let
  lib = nixpkgs.lib;
  hosts = import (flakeRoot + /lib/hosts.nix);
  deploy-rs = inputs.deploy-rs;
  opnix = inputs.opnix;
  # Hosts that deploy-rs targets (nixos hosts with an `ip`).
  deployableHosts = lib.filterAttrs (_: h: h.type == "nixos" && h ? ip) hosts;

  mkDarwin = {
    name,
    system,
    specialArgs,
    extraModules ? [],
  }: let
    mergedSpecialArgs = specialArgs // {isDarwin = true;};
  in
    nix-darwin.lib.darwinSystem {
      specialArgs = mergedSpecialArgs;
      modules =
        [
          {nixpkgs.hostPlatform = system;}
          {nixpkgs.overlays = [inputs.auxera.overlays.default (import (flakeRoot + /overlays/opencode-fix.nix)) (import (flakeRoot + /overlays/helm-fix.nix))];}
          (flakeRoot + /hosts/common/config.nix)
          (flakeRoot + /modules/system)
          (flakeRoot + /modules/system/platform/darwin.nix)
          (flakeRoot + /hosts/common/system.nix)
          (flakeRoot + /hosts/${name}/system.nix)
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = mergedSpecialArgs;
              users.${specialArgs.username} = {
                imports = [
                  inputs.auxera.homeManagerModules.default
                  (flakeRoot + /modules/home)
                  (flakeRoot + /hosts/common/home.nix)
                  (flakeRoot + /hosts/${name}/home.nix)
                  catppuccin.homeModules.catppuccin
                ];
              };
            };
          }
        ]
        ++ extraModules;
    };

  mkNixos = {
    name,
    system,
    specialArgs,
    extraModules ? [],
    withHomeManager ? true,
    isWsl ? false,
  }: let
    mergedSpecialArgs =
      specialArgs
      // {
        isDarwin = false;
        inherit isWsl;
        modulesPath = "${nixpkgs}/nixos/modules";
      };
  in
    nixpkgs.lib.nixosSystem {
      specialArgs = mergedSpecialArgs;
      modules =
        [
          {nixpkgs.hostPlatform = system;}
          {nixpkgs.overlays = [inputs.auxera.overlays.default (import (flakeRoot + /overlays/opencode-fix.nix)) (import (flakeRoot + /overlays/helm-fix.nix))];}
          (flakeRoot + /hosts/common/config.nix)
          (flakeRoot + /modules/system)
          (flakeRoot + /modules/system/platform/nixos.nix)
          (flakeRoot + /hosts/common/system.nix)
          (flakeRoot + /hosts/${name}/system.nix)
        ]
        ++ (
          if withHomeManager
          then [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = mergedSpecialArgs;
                users.${specialArgs.username} = {
                  imports = [
                    inputs.auxera.homeManagerModules.default
                    (flakeRoot + /modules/home)
                    (flakeRoot + /hosts/common/home.nix)
                    (flakeRoot + /hosts/${name}/home.nix)
                    catppuccin.homeModules.catppuccin
                  ];
                };
              };
            }
          ]
          else []
        )
        ++ extraModules;
    };
in {
  inherit hosts;

  # Generate darwinConfigurations from the host registry.
  mkDarwinConfigurations = lib.mapAttrs (name: host:
    mkDarwin {
      inherit name;
      system = host.system;
      specialArgs = {
        username = host.username;
        inherit inputs;
      };
      extraModules = [opnix.darwinModules.default] ++ (host.extraModules or (_: [])) inputs;
    })
  (lib.filterAttrs (_: h: h.type == "darwin") hosts);

  # Generate nixosConfigurations from the host registry.
  mkNixosConfigurations = lib.mapAttrs (name: host:
    mkNixos {
      inherit name;
      system = host.system;
      specialArgs = {
        username = host.username;
        inherit inputs;
      };
      withHomeManager = host.withHomeManager or false;
      isWsl = host.isWsl or false;
      extraModules = [opnix.nixosModules.default] ++ (host.extraModules or (_: [])) inputs;
    })
  (lib.filterAttrs (_: h: h.type == "nixos") hosts);

  # Generate deploy-rs nodes from the host registry. Shared deploy-rs defaults
  # (magicRollback, remoteBuild, root user) live here once instead of per-node.
  mkDeployNodes = {nixosConfigurations}:
    lib.mapAttrs (name: host: {
      hostname = host.ip;
      sshUser = host.deployUser;
      user = "root";
      profiles.system.path = deploy-rs.lib.${host.system}.activate.nixos nixosConfigurations.${name};
      magicRollback = true;
      remoteBuild = true;
    })
    deployableHosts;

  # Generate deploy-rs checks grouped by system from the host registry.
  mkDeployChecks = {deployNodes}:
    builtins.listToAttrs
    (map (system: {
        name = system;
        value = deploy-rs.lib.${system}.deployChecks {
          nodes = lib.filterAttrs (_: h: h.system == system) deployNodes;
        };
      })
      (lib.unique (lib.mapAttrsToList (_: h: h.system) deployableHosts)));
}
