{
  lib,
  pkgs,
  config,
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
    # Only the `default` shell is configured on the home side (plugins,
    # aliases, prompt/fzf/direnv integrations). The other shell may still be
    # installed at the system level as a bare fallback (see modules/system/shell.nix)
    # but gets no home-manager config. Override `myModules.home.<shell>.enable`
    # to configure both.
    myModules.home = {
      zsh.enable = lib.mkDefault (cfg.default == "zsh");
      fish.enable = lib.mkDefault (cfg.default == "fish");
    };
    myModules.home.shell.aliases = lib.optionalAttrs pkgs.stdenv.isDarwin {
      finder = "open";
    };
  };
}
