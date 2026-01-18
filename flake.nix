{
  description = "Flake for managing my NixOS, nix-darwin, and WSL systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
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

    agent-skills-nix = {
      url = "github:kyure-a/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vercel-agent-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };

    expo-agent-skills = {
      url = "github:expo/skills";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    opnix,
    opencode,
    nix-darwin,
    nixos-wsl,
    nixpkgs,
    flake-utils,
    home-manager,
    agent-skills-nix,
    vercel-agent-skills,
    expo-agent-skills,
  }: let
    lib = (import ./lib) {
      inherit nixpkgs nix-darwin nixos-wsl home-manager;
      flakeRoot = ./.;
    };
    inherit (lib) mkDarwin mkNixos;
  in
    (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            alejandra
          ];
        };
      }
    ))
    // {
      # Build darwin flake using:
      darwinConfigurations = {
        darwin = mkDarwin {
          name = "darwin";
          specialArgs = {
            me = {
              username = "felix.berger";
              homePrefix = "/Users/felix.berger";
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuBvk3U7Pdlf5vUV6eH1VvUDigRHDRMp+d+pdo7jTky main-key";
            };
            inherit inputs;
          };
          extraModules = [
            opnix.darwinModules.default
          ];
        };
      };

      # Build nixosConfigurations using:
      nixosConfigurations = {
        wsl-devbox = mkNixos {
          name = "wsl-devbox";
          system = "x86_64-linux";
          specialArgs = {
            me = {
              username = "nixos";
              homePrefix = "/home/nixos";
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuBvk3U7Pdlf5vUV6eH1VvUDigRHDRMp+d+pdo7jTky main-key";
            };
            inherit inputs;
          };
          withHomeManager = true;
          extraModules = [
            opnix.nixosModules.default
            nixos-wsl.nixosModules.default
          ];
        };

        k3s-node = mkNixos {
          name = "k3s-node";
          system = "x86_64-linux";
          specialArgs = {
            me = {
              username = "nixos";
              homePrefix = "/home/nixos";
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuBvk3U7Pdlf5vUV6eH1VvUDigRHDRMp+d+pdo7jTky main-key";
            };
            inherit inputs;
          };
          withHomeManager = false;
          extraModules = [
            opnix.nixosModules.default
          ];
        };

        master-node = mkNixos {
          name = "master-node";
          system = "x86_64-linux";
          specialArgs = {
            me = {
              username = "nixos";
              homePrefix = "/home/nixos";
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuBvk3U7Pdlf5vUV6eH1VvUDigRHDRMp+d+pdo7jTky main-key";
            };
            inherit inputs;
          };
          withHomeManager = false;
          extraModules = [
            opnix.nixosModules.default
          ];
        };
      };
    };
}
