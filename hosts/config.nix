{
  config,
  lib,
  pkgs,
  ...
}: let
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuBvk3U7Pdlf5vUV6eH1VvUDigRHDRMp+d+pdo7jTky main-key";

  hostConfig =
    if pkgs.stdenv.isDarwin
    then {
      username = "felix.berger";
      homePrefix = "/Users/felix.berger";
      editor = "zed";
    }
    else {
      username = "nixos";
      homePrefix = "/home/nixos";
      editor = "nvim";
    };

  globalConfig = {
    dotfiles = "${hostConfig.homePrefix}/dotfiles";
    publicKey = publicKey;
    sshKeys = [publicKey];
  };
in {
  config.var = lib.recursiveUpdate globalConfig hostConfig;

  options.var = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Global configuration variables available to all modules";
  };
}
