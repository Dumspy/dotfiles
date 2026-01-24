{lib, ...}: {
  options.myModules.home.portable = lib.mkEnableOption "portable mode (avoid nix store paths in configs)";
}
