{
  description = "Flake for managing my NixOS, nix-darwin, and WSL systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixos-wsl,
    nixpkgs,
    home-manager,
    sops-nix,
  }: {
    # Build darwin flake using:
    darwinConfigurations."Felixs-MacBook-Air" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        sops-nix.nixosModules.sops
        ./hosts/system.nix
        ./hosts/darwin/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."felix.berger" = import ./hosts/darwin/home.nix;
          };
        }
      ];
    };

    # Build nixosConfigurations using:
    nixosConfigurations = {
      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          sops-nix.nixosModules.sops
          ./hosts/system.nix
          ./hosts/wsl/wsl.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nixos = import ./hosts/wsl/home.nix;
            };
          }
        ];
      };

      docker-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/system.nix
          ./hosts/docker-host/docker-host.nix
        ];
      };
    };

    # darwinPackages = self.darwinConfigurations."Felixs-MacBook-Air".pkgs;
  };
}
