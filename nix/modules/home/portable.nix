{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.portable;
in {
  options.modules.portable = {
    enable = lib.mkEnableOption "portable dotfiles export mode";
  };

  config = lib.mkIf cfg.enable {
    # Prevent this configuration from being applied to a real system
    home.activation.abortOnSwitch = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      echo "ABORTING: Portable mode is enabled. This configuration is for export only and cannot be activated."
      exit 1
    '';
  };
}
