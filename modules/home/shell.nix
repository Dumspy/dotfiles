{
  config,
  lib,
  pkgs,
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
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Shell aliases to apply across all shells";
    };
  };

  config = {
    myModules.home = {
      zsh.enable = lib.mkDefault true;
      fish.enable = lib.mkDefault true;
    };
    myModules.home.shell.aliases = lib.optionalAttrs pkgs.stdenv.isDarwin {
      finder = "open";
    };
  };
}
