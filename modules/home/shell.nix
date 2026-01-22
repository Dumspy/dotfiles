{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.shell;
in {
  options.myModules.home.shell = {
    default = lib.mkOption {
      type = lib.types.enum ["zsh" "fish"];
      default = "zsh";
      description = "Default shell to use";
    };
  };

  config = {
    myModules.home = {
      zsh.enable = lib.mkDefault true;
      fish.enable = lib.mkDefault true;
    };
  };
}
