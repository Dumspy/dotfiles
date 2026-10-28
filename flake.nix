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

    # Preview until the first stable tag exists. stable.tar.gz is 404 "Blob not found";
    # the install script falls back to preview in that case. Needs a netrc for
    # pkgs.superlogical.com.
    rex = {
      url = "https://pkgs.superlogical.com/rex/nix/preview.tar.gz";
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
    rex,
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

      checks = let
        rexHosts = [
          "wsl-devbox"
          "k3s-node"
          "oci-node-1"
          "oci-node-2"
          "oci-node-3"
        ];
        # Evaluates every NixOS host. deployChecks below does not include wsl-devbox.
        rexSummary =
          nixpkgs.lib.concatMapStringsSep "\n" (
            name: let
              cfg = self.nixosConfigurations.${name}.config;
              ts = cfg.services.rex.tailscale;
            in
              nixpkgs.lib.concatStringsSep " " [
                "host=${name}"
                "hostname=${ts.hostname}"
                "user=${cfg.users.users.rex.name}"
                "enabled=${nixpkgs.lib.boolToString cfg.services.rex.enable}"
                "tags=${nixpkgs.lib.concatStringsSep "," ts.advertiseTags}"
                "members=${nixpkgs.lib.boolToString ts.allowTailnetMembers}"
                "auth=${ts.authKeyFile}"
                "mode=${cfg.services.onepassword-secrets.secrets.rexAuthKey.mode}"
                "after=${nixpkgs.lib.concatStringsSep "," cfg.systemd.services.rex.after}"
              ]
          )
          rexHosts;
      in {
        x86_64-linux =
          deploy-rs.lib.x86_64-linux.deployChecks {
            nodes = {
              k3s-node = self.deploy.nodes.k3s-node;
            };
          }
          // {
            rex-nixos = nixpkgs.legacyPackages.x86_64-linux.runCommand "rex-nixos" {} ''
              cat > "$out" <<EOF
              ${rexSummary}
              EOF
              for host in wsl-devbox k3s-node oci-node-1 oci-node-2 oci-node-3; do
                grep -q "^host=''${host} hostname=rex-''${host} user=rex enabled=true tags=tag:rex members=true auth=/var/lib/opnix/secrets/rexAuthKey mode=0400 after=.*opnix-secrets.service" "$out"
              done
            '';
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
