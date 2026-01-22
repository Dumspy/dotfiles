{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.shell;
  isDarwin = pkgs.stdenv.isDarwin;
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
    myModules.home.shell.aliases = lib.optionalAttrs isDarwin {
      finder = "open";
    };
  };
}
