{
  config,
  lib,
  inputs,
  username,
  ...
}: let
  cfg = config.myModules.system.rex;
  hostTailscale = config.services.tailscale.enable;
in {
  imports = [
    inputs.rex.nixosModules.default
  ];

  options.myModules.system.rex = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run Rex's login server, so sessions run as `account` instead of the
        shared server's `rex` user.
      '';
    };

    account = lib.mkOption {
      type = lib.types.str;
      default = username;
      description = ''
        Account the login server runs sessions as. Must already exist; Rex only
        writes the accounts file.
      '';
    };

    principals = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "tailscale:tag:daily-driver"
        "tailscale:tag:phone"
      ];
      description = ''
        Rex principals allowed to use `account`. This tailnet identifies callers
        by tag, not by user login.
      '';
    };

    tailnetPort = lib.mkOption {
      type = lib.types.port;
      default = 7297;
      description = ''
        Port of the `tailnet://` listener, opened on `tailscale0`. Ignored on
        hosts without Tailscale.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.account config.users.users;
        message = "myModules.system.rex.account must name an existing user account.";
      }
    ];

    services.rex.loginServer = {
      enable = true;
      accounts.${cfg.account}.principals = cfg.principals;
      defaults = lib.genAttrs cfg.principals (_: cfg.account);

      # Tagged callers need `tailnet://`; Serve does not forward their identity.
      extraListen = lib.optional hostTailscale "tailnet://:${toString cfg.tailnetPort}";
    };

    # The module never opens `extraListen` ports itself.
    networking.firewall.interfaces."tailscale0".allowedTCPPorts =
      lib.optional hostTailscale cfg.tailnetPort;
  };
}
