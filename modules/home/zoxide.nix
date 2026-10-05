{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.zoxide;
in {
  options.myModules.home.zoxide = {
    enable = lib.mkEnableOption "zoxide smart directory navigator";

    replaceCd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Replace the builtin cd command with zoxide's smart cd.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = config.myModules.home.zsh.enable;
      enableFishIntegration = config.myModules.home.fish.enable;
      options = lib.optionals cfg.replaceCd ["--cmd cd"];
    };
  };
}
