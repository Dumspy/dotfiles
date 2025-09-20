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
    darwinConfigurations = let
      me = {
        username = "felix.berger";
        homePrefix = "/Users/felix.berger";
      };
    in let
      specialArgs = {inherit me;};
    in {
      darwin = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = specialArgs;
        modules = [
          sops-nix.darwinModules.sops
          ./hosts/system.nix
          ./hosts/darwin/system.nix
          home-manager.darwinModules.home-manager
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
      specialArgs = {inherit me;};
    in {
      wsl-devbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs;
        modules = [
          nixos-wsl.nixosModules.default
          sops-nix.nixosModules.sops
          ./hosts/system.nix
          ./hosts/wsl-devbox/system.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${me.username} = import ./hosts/wsl/home.nix;
            };
          }
        ];
      };

      k3s-node = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs;
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/system.nix
          ./hosts/k3s-node/system.nix
        ];
      };

      master-node = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs;
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/system.nix
          ./hosts/master-node/system.nix
        ];
      };
    };
  };
}
