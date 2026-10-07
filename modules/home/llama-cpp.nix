{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.llama-cpp;

  # Pinned v0.6.0 (newest stable, minimum for Clef decision models +
  # /v1/systemone API). Vendored from nixpkgs master
  # (pkgs/by-name/ll/llama-cpp/package.nix) because nixpkgs-unstable in
  # flake.lock still ships b10273. Drop this and default back to
  # pkgs.llama-cpp once `nix eval nixpkgs#llama-cpp.version` reports >= 0.6.0.
  # Metal is on by default on darwin (GGML_METAL=TRUE, embedded library).
  pinned = pkgs.callPackage ../../packages/llama-cpp/package.nix {};
in {
  options.myModules.home.llama-cpp = {
    enable = lib.mkEnableOption "llama.cpp LLM inference (Metal-accelerated on darwin)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pinned;
      description = ''
        llama.cpp package to install. Defaults to the pinned v0.6.0 in
        packages/llama-cpp. Override for nightlies/HEAD, e.g. to track a
        newer `b114xx` nightly when you need something beyond stable.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
