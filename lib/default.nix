{
  nixpkgs,
  nix-darwin,
  home-manager,
  catppuccin,
  inputs,
  flakeRoot ? ./..,
  ...
}: {
  mkDarwin = {
    name,
    specialArgs,
    extraModules ? [],
  }:
    nix-darwin.lib.darwinSystem {
      specialArgs = specialArgs // {isDarwin = true;};
      modules =
        [
          {nixpkgs.hostPlatform = "aarch64-darwin";}
          {nixpkgs.overlays = [inputs.auxera.overlays.default];}
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
              extraSpecialArgs = specialArgs;
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
  }:
    nixpkgs.lib.nixosSystem {
      specialArgs =
        specialArgs
        // {
          isDarwin = false;
          inherit isWsl;
          modulesPath = "${nixpkgs}/nixos/modules";
        };
      modules =
        [
          {nixpkgs.hostPlatform = system;}
          {nixpkgs.overlays = [inputs.auxera.overlays.default];}
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
                extraSpecialArgs = specialArgs;
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
}
