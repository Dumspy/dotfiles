{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.lazygit;
in {
  options.myModules.home.lazygit = {
    enable = lib.mkEnableOption "lazygit terminal UI for git";
  };

  config = lib.mkIf cfg.enable {
    programs.lazygit.enable = true;
  };
}
