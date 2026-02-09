{
  nixpkgs,
  nix-darwin,
  home-manager,
  catppuccin,
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
          (flakeRoot + /hosts/config.nix)
          (flakeRoot + /modules/system)
          (flakeRoot + /modules/system/platform/darwin.nix)
          (flakeRoot + /hosts/system.nix)
          (flakeRoot + /hosts/${name}/system.nix)
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${specialArgs.username} = {
                imports = [
                  (flakeRoot + /modules/home)
                  (flakeRoot + /hosts/home.nix)
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
  }:
    nixpkgs.lib.nixosSystem {
      specialArgs =
        specialArgs
        // {
          isDarwin = false;
          modulesPath = "${nixpkgs}/nixos/modules";
        };
      modules =
        [
          {nixpkgs.hostPlatform = system;}
          (flakeRoot + /hosts/config.nix)
          (flakeRoot + /modules/system)
          (flakeRoot + /modules/system/platform/nixos.nix)
          (flakeRoot + /hosts/system.nix)
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
                    (flakeRoot + /modules/home)
                    (flakeRoot + /hosts/home.nix)
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
