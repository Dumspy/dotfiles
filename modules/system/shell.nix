{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.shell;
in {
  options.myModules.system.shell = {
    default = lib.mkOption {
      type = lib.types.enum ["zsh" "fish"];
      default = "zsh";
      description = "Default system shell";
    };
  };

  config = {
    environment.systemPackages =
      [
        pkgs.zsh
        pkgs.ripgrep
      ]
      ++ lib.optional (cfg.default == "fish") pkgs.fish;

    programs.fish.enable = cfg.default == "fish";
    # zsh is always enabled as a bare fallback shell (it gets full home-manager
    # config only when it is the `default`; see modules/home/shell.nix).
    programs.zsh = {
      enable = true;
      shellInit = ''
        setopt HIST_IGNORE_SPACE
      '';
    };
  };
}
