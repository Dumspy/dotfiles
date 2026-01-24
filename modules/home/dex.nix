{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.dex;
  dex = pkgs.callPackage ../../packages/dex/package.nix {
    fetchNpmDepsWithPackuments = pkgs.fetchNpmDeps;
    npmConfigHook = pkgs.npmHooks.npmConfigHook;
  };
in {
  options.myModules.home.dex = {
    enable = lib.mkEnableOption "dex CLI for task tracking in LLM workflows";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [dex];
  };
}
