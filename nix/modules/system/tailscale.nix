{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.tailscale;
in {
  options.myModules.system.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.tailscale];
    services.tailscale.enable = true;
  };
}
