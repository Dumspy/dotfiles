{
  description = "Flake for managing my NixOS, nix-darwin, and WSL systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auxera = {
      url = "github:Auxera/nixpkgs";
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

    dot-agents = {
      url = "github:Dumspy/dot-agents";
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
    nix-darwin,
    nixos-wsl,
    nixpkgs,
    home-manager,
    catppuccin,
    auxera,
    ...
  }: let
    myLib = (import ./lib) {
      inherit nixpkgs nix-darwin nixos-wsl home-manager catppuccin;
      inherit inputs;
      flakeRoot = ./.;
    };
    inherit (myLib) mkDarwinConfigurations mkNixosConfigurations mkDeployNodes mkDeployChecks;
    nixosConfigurations = mkNixosConfigurations;
    deployNodes = mkDeployNodes {inherit nixosConfigurations;};
    defaultSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
  in {
    # formatter per system (replaces flake-utils.lib.eachDefaultSystem).
    formatter = nixpkgs.lib.genAttrs defaultSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [auxera.overlays.default];
        };
      in
        pkgs.alejandra
    );

    # Host configurations and deploy-rs targets are generated from
    # lib/hosts.nix (the single source of truth). See lib/default.nix.
    darwinConfigurations = mkDarwinConfigurations;
    inherit nixosConfigurations;
    deploy.nodes = deployNodes;
    checks = mkDeployChecks {inherit deployNodes;};
  };
}
