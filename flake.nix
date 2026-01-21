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
      url = "github:vercel-labs/agent-skills/dd157cbd26f5c1f1154214035d3f8c9d7fe87a1c";
      flake = false;
    };

    expo-agent-skills = {
      url = "github:expo/skills/7b7ecb2a304ae94168aa45ad1de936ec59b9a949";
      flake = false;
    };

    agent-browser = {
      url = "github:vercel-labs/agent-browser/399fd7a434583896ff11944e870ab480f1945f8b";
      flake = false;
    };

    anthropics-agent-skills = {
      url = "github:anthropics/skills/69c0b1a0674149f27b61b2635f935524b6add202";
      flake = false;
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    agent-browser,
    anthropics-agent-skills,
    llm-agents,
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
            username = "felix.berger";
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
            username = "nixos";
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
            username = "nixos";
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
            username = "nixos";
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
