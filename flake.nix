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

    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
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
    git-hooks,
    home-manager,
    agent-skills-nix,
    vercel-agent-skills,
    expo-agent-skills,
    agent-browser,
    anthropics-agent-skills,
    dex-agent-skills,
    claude-plugins-official,
    sentry-skills,
    llm-agents,
    catppuccin,
  }: let
    lib = (import ./lib) {
      inherit nixpkgs nix-darwin nixos-wsl home-manager catppuccin;
      flakeRoot = ./.;
    };
    inherit (lib) mkDarwin mkNixos;
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

      # Portable home-manager configuration for cross-platform dotfiles export
      homeConfigurations.portable = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "x86_64-linux";};
        extraSpecialArgs = {inherit inputs;};
        modules = [
          {
            home.username = "user";
            home.homeDirectory = "/home/user";
            home.stateVersion = "24.11";
            imports = [
              ./modules/home/portable.nix
            ];
          }
        ];
      };
    };
}
