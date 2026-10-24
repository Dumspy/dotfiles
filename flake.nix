{
  description = "Flake for managing my NixOS, nix-darwin, and WSL systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

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
      url = "github:Dumspy/dot-agents";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hunk = {
      url = "github:modem-dev/hunk";
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
    home-manager,
    dot-agents,
    catppuccin,
    hunk,
    lazyvim,
    deploy-rs,
    auxera,
  }: let
    myLib = (import ./lib) {
      inherit
        nixpkgs
        nix-darwin
        nixos-wsl
        home-manager
        catppuccin
        ;
      inherit inputs;
      flakeRoot = ./.;
    };
    inherit (myLib) mkDarwin mkNixos;

    # `nix flake check` instantiates every nixosConfigurations toplevel, but it
    # treats darwinConfigurations as an unchecked output. The full darwin
    # toplevel depends on catppuccin's starship port, an aarch64-darwin
    # import-from-derivation that cannot build on the Linux runner. This check
    # forces a slice that stays pure data: platform, Home Manager user, and the
    # git ssh-sign program. It does not use deploy-rs.
    evalDarwin = let
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {system = "x86_64-linux";};
      slices =
        lib.mapAttrs (
          _: cfg: let
            users = cfg.config.home-manager.users;
            user = builtins.head (builtins.attrNames users);
            home = users.${user};
          in {
            system = cfg.config.nixpkgs.hostPlatform.system;
            inherit user;
            homeDirectory = home.home.homeDirectory;
            username = home.home.username;
            stateVersion = home.home.stateVersion;
            gitSshProgram = home.programs.git.settings.gpg.ssh.program or "";
          }
        )
        self.darwinConfigurations;
    in
      assert builtins.length (builtins.attrNames slices) > 0;
      assert lib.all (
        slice:
          lib.elem slice.system ["aarch64-darwin" "x86_64-darwin"]
          && slice.homeDirectory != ""
          && slice.username != ""
          && slice.stateVersion != ""
      )
      (lib.attrValues slices);
        builtins.deepSeq slices (
          pkgs.runCommand "eval-darwin" {
            preferLocalBuild = true;
            allowSubstitutes = false;
          } ''
            mkdir -p "$out"
            echo ok > "$out/ok"
          ''
        );
  in
    (flake-utils.lib.eachSystem ["aarch64-darwin" "aarch64-linux" "x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [auxera.overlays.default];
        };
      in {
        formatter = pkgs.alejandra;
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

      # Keep `eval-darwin` when removing deploy-rs. Drop only the
      # `// deploy-rs.lib.*.deployChecks` overlays; `nix flake check` still
      # instantiates nixosConfigurations without them.
      checks = {
        x86_64-linux =
          {
            eval-darwin = evalDarwin;
          }
          // deploy-rs.lib.x86_64-linux.deployChecks {
            nodes = {
              k3s-node = self.deploy.nodes.k3s-node;
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
