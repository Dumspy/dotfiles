{
  config,
  lib,
  ...
}:
let
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuBvk3U7Pdlf5vUV6eH1VvUDigRHDRMp+d+pdo7jTky main-key";

  # Shared config for all non-darwin systems
  linuxDefault = {
    username = "nixos";
    homePrefix = "/home/nixos";
    editor = "nvim";
  };

  # Per-host config overrides
  hostConfigs = {
    darwin = {
      username = "felix.berger";
      homePrefix = "/Users/felix.berger";
      editor = "zed";
    };
    wsl-devbox = {
      npiperelayPath = "/mnt/c/bin/npiperelay.exe";
    };
  };

  # Get current host config
  hostName = config.networking.hostName or "default";

  # Merge base with host-specific overrides
  mergedHostConfig = lib.recursiveUpdate linuxDefault (hostConfigs.${hostName} or { });
  hostConfig = if hostName == "darwin" then hostConfigs.darwin else mergedHostConfig;

  globalConfig = {
    dotfiles = "${hostConfig.homePrefix}/dotfiles";
    publicKey = publicKey;
    sshKeys = [ publicKey ];
  };
in
{
  config.var = lib.recursiveUpdate globalConfig hostConfig;

  options.var = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Global configuration variables available to all modules";
  };
}
