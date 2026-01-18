{
  nixpkgs,
  nix-darwin,
  nixos-wsl,
  home-manager,
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
          ./modules/system
          ./hosts/system.nix
          ./hosts/${name}/system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${specialArgs.me.username} = {
                imports = [
                  ./modules/home
                  ./hosts/home.nix
                  ./hosts/${name}/home.nix
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
          ./modules/system
          ./hosts/system.nix
          ./hosts/${name}/system.nix
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
                    ./modules/home
                    ./hosts/home.nix
                    ./hosts/${name}/home.nix
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
