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

    vercel-agent-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };

    expo-agent-skills = {
      url = "github:expo/skills";
      flake = false;
    };

    agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };

    anthropics-agent-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    dex-agent-skills = {
      url = "github:dcramer/dex";
      flake = false;
    };

    sentry-skills = {
      url = "github:getsentry/skills";
      flake = false;
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

  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

  outputs = inputs @ {
    self,
    opnix,
    opencode,
    nix-darwin,
    nixos-wsl,
    nixpkgs,
    flake-utils,
    git-hooks,
    home-manager,
    vercel-agent-skills,
    expo-agent-skills,
    agent-browser,
    anthropics-agent-skills,
    dex-agent-skills,
    sentry-skills,
    llm-agents,
    catppuccin,
    lazyvim,
    deploy-rs,
  }: let
    myLib = (import ./lib) {
      inherit nixpkgs nix-darwin nixos-wsl home-manager catppuccin;
      flakeRoot = ./.;
    };
    inherit (myLib) mkDarwin mkNixos;
  in
    (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
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
          packages = [pkgs.alejandra];
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

      # Portable home-manager configuration for cross-platform dotfiles export
      homeConfigurations.portable = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "x86_64-linux";};
        extraSpecialArgs = {inherit inputs;};
        modules = [
          catppuccin.homeModules.catppuccin
          ./modules/home/portable.nix
        ];
      };

      deploy.nodes = {
        oci-node-1 = {
          hostname = "100.99.30.112";
          sshUser = "deploy";
          user = "root";
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.oci-node-1;
          magicRollback = true;
          remoteBuild = true;
        };

        oci-node-2 = {
          hostname = "100.120.122.114";
          sshUser = "deploy";
          user = "root";
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.oci-node-2;
          magicRollback = true;
          remoteBuild = true;
        };

        oci-node-3 = {
          hostname = "100.64.54.67";
          sshUser = "deploy";
          user = "root";
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.oci-node-3;
          magicRollback = true;
          remoteBuild = true;
        };

        k3s-node = {
          hostname = "100.109.48.72";
          sshUser = "deploy";
          user = "root";
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.k3s-node;
          magicRollback = true;
          remoteBuild = true;
        };

        master-node = {
          hostname = "100.83.126.36";
          sshUser = "deploy";
          user = "root";
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.master-node;
          magicRollback = true;
          remoteBuild = true;
        };
      };

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
