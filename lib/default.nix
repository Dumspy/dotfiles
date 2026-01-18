{
  nixpkgs,
  nix-darwin,
  nixos-wsl,
  home-manager,
  flakeRoot ? ./..,
  ...
}: {
  mkDarwin = {
    name,
    specialArgs,
    extraModules ? [],
  }:
    nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules =
        [
          {nixpkgs.hostPlatform = "aarch64-darwin";}
          (flakeRoot + /modules/system)
          (flakeRoot + /hosts/system.nix)
          (flakeRoot + /hosts/${name}/system.nix)
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${specialArgs.me.username} = {
                imports = [
                  (flakeRoot + /modules/home)
                  (flakeRoot + /hosts/home.nix)
                  (flakeRoot + /hosts/${name}/home.nix)
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
      inherit specialArgs;
      modules =
        [
          {nixpkgs.hostPlatform = system;}
          (flakeRoot + /modules/system)
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
                users.${specialArgs.me.username} = {
                  imports = [
                    (flakeRoot + /modules/home)
                    (flakeRoot + /hosts/home.nix)
                    (flakeRoot + /hosts/${name}/home.nix)
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
