{
  config,
  lib,
  isDarwin,
  ...
}: let
  cfg = config.myModules.system.openssh;
in {
  options.myModules.system.openssh = {
    enable = lib.mkEnableOption "OpenSSH server";
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Authorized public keys for SSH access";
    };
    tailscaleOnly = lib.mkEnableOption "SSH only on tailscale0";
  };

  # nix-darwin has no firewall and a different openssh module. Keep it out of
  # the attrset entirely so those options are never defined there.
  config = lib.mkMerge (
    [
      (lib.mkIf cfg.enable {
        services.openssh.enable = true;
        users.users."${config.var.username}".openssh.authorizedKeys.keys = cfg.authorizedKeys;
      })
    ]
    ++ lib.optionals (!isDarwin) [
      (lib.mkIf cfg.enable {
        services.openssh.settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          # Key-only. "no" would also reject root keys.
          PermitRootLogin = "prohibit-password";
        };
      })
      # sshd keeps listening on every address. Binding it to the Tailscale IP
      # would fail at boot, before tailscaled creates tailscale0. The firewall
      # rule matches the interface name and is valid before the interface exists.
      (lib.mkIf (cfg.enable && cfg.tailscaleOnly) {
        services.openssh.openFirewall = false;
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [22];
      })
    ]
  );
}
