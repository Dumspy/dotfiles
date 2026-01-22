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
      ]
      ++ lib.optional (cfg.default == "fish") pkgs.fish;

    programs.fish.enable = cfg.default == "fish";
    programs.zsh = {
      enable = true;
      shellInit = ''
        setopt HIST_IGNORE_SPACE
      '';
    };

    users.defaultUserShell =
      if cfg.default == "fish"
      then pkgs.fish
      else pkgs.zsh;
  };
}
