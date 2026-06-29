{
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
    }
    else {
      username = "nixos";
      homePrefix = "/home/nixos";
    };

  globalConfig = {
    dotfiles = "${hostConfig.homePrefix}/dotfiles";
    publicKey = publicKey;
    sshKeys = [publicKey];
    # Editor is nvim everywhere: it's a blocking terminal editor that works
    # as git's core.editor / $EDITOR out of the box, and it's installed on
    # every host via the lazyvim home module. (A `zed` editor was previously
    # declared here for darwin but never wired in, and `zed` doesn't block
    # without `--wait` so it isn't a drop-in for $EDITOR.) This is the single
    # source consumed by modules/home/{git,lazyvim}.nix.
    editor = "nvim";
  };
in {
  config.var = lib.recursiveUpdate globalConfig hostConfig;

  options.var = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Global configuration variables available to all modules";
  };
}
