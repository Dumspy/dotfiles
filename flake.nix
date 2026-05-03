{
  description = "Flake for managing my NixOS, nix-darwin, and WSL systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auxera = {
      url = "github:Auxera/nixpkgs";
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

    dot-agents = {
      url = "path:/home/nixos/Documents/dot-agents";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    opnix,
    nix-darwin,
    nixos-wsl,
    nixpkgs,
    flake-utils,
    git-hooks,
    home-manager,
    dot-agents,
    llm-agents,
    catppuccin,
    lazyvim,
    deploy-rs,
    auxera,
  }: let
    myLib = (import ./lib) {
      inherit nixpkgs nix-darwin nixos-wsl home-manager catppuccin;
      inherit inputs;
      flakeRoot = ./.;
    };
    inherit (myLib) mkDarwin mkNixos;
  in
    (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [auxera.overlays.default];
        };
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
          };
        };
      in {
        checks = {inherit pre-commit-check;};
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell {
          inherit (pre-commit-check) shellHook;
          packages = [pkgs.alejandra pkgs.deadnix];
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
          isWsl = true;
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

        oci-node-1 = mkNixos {
          name = "oci-node-1";
          system = "aarch64-linux";
          specialArgs = {
            username = "nixos";
            inherit inputs;
          };
          withHomeManager = false;
          extraModules = [
            opnix.nixosModules.default
          ];
        };

        oci-node-2 = mkNixos {
          name = "oci-node-2";
          system = "aarch64-linux";
          specialArgs = {
            username = "nixos";
            inherit inputs;
          };
          withHomeManager = false;
          extraModules = [
            opnix.nixosModules.default
          ];
        };

        oci-node-3 = mkNixos {
          name = "oci-node-3";
          system = "aarch64-linux";
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

      deploy.nodes = import ./nix/deploy.nix {inherit self deploy-rs;};

      checks = {
        x86_64-linux = deploy-rs.lib.x86_64-linux.deployChecks {
          nodes = {
            k3s-node = self.deploy.nodes.k3s-node;
            master-node = self.deploy.nodes.master-node;
          };
        };
        aarch64-linux = deploy-rs.lib.aarch64-linux.deployChecks {
          nodes = {
            oci-node-1 = self.deploy.nodes.oci-node-1;
            oci-node-2 = self.deploy.nodes.oci-node-2;
            oci-node-3 = self.deploy.nodes.oci-node-3;
          };
        };
      };
    };
}
