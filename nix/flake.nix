{
  description = "Flake for managing my NixOS, nix-darwin, and WSL systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    opnix = {
      url = "github:brizzbuzz/opnix/v0.7.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    opnix,
    nix-darwin,
    nixos-wsl,
    nixpkgs,
    home-manager,
  }: {
    # Build darwin flake using:
    darwinConfigurations = let
      me = {
        username = "felix.berger";
        homePrefix = "/Users/felix.berger";
      };
    in let
      specialArgs = {inherit me inputs;};
    in {
      darwin = nix-darwin.lib.darwinSystem {
        specialArgs = specialArgs;
        modules = [
          {nixpkgs.hostPlatform = "aarch64-darwin";}

          opnix.darwinModules.default
          home-manager.darwinModules.home-manager
          ./hosts/system.nix
          ./hosts/darwin/system.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${me.username} = import ./hosts/darwin/home.nix;
            };
          }
        ];
      };
    };

    # Build nixosConfigurations using:
    nixosConfigurations = let
      me = {
        username = "nixos";
        homePrefix = "/home/nixos";
      };
    in let
      specialArgs = {inherit me inputs;};
    in {
      wsl-devbox = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs;
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}

          opnix.nixosModules.default
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/system.nix
          ./hosts/wsl-devbox/system.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${me.username} = import ./hosts/wsl-devbox/home.nix;
            };
          }
        ];
      };

      k3s-node = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs;
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}

          opnix.nixosModules.default
          ./hosts/system.nix
          ./hosts/k3s-node/system.nix
        ];
      };

      master-node = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs;
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}

          opnix.nixosModules.default
          ./hosts/system.nix
          ./hosts/master-node/system.nix
        ];
      };
    };
  };
}
