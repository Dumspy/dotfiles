{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.neovim;
in {
  options.myModules.home.neovim = {
    enable = lib.mkEnableOption "neovim editor";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
