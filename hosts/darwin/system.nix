{
  config,
  pkgs,
  opencode,
  ...
}: {
  nix.enable = true;

  system.primaryUser = config.var.username;

  home-manager.backupFileExtension = "bak";

  #homebrew
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "discord"
      "arc"
      "docker"
      "ghostty"
      "spotify"
      "raycast"
      "zed"
      "visual-studio-code"
      "bruno"
      "dbeaver-community"
      "tailscale-app"
      "steipete/tap/codexbar"
    ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
  };

  #Users
  users.knownUsers = [config.var.username];
  users.users."${config.var.username}" = {
    uid = 501;
    gid = 20;
    home = "/Users/${config.var.username}";
    shell =
      if config.myModules.system.shell.default == "fish"
      then pkgs.fish
      else pkgs.zsh;
  };

  # Register shells in /etc/shells (required for macOS to treat them as valid login shells)
  # Note: nix-darwin doesn't automatically update /etc/shells, must include both
  environment.shells = [
    pkgs.zsh
    pkgs.fish
  ];

  environment.systemPackages = [
    opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.amp-cli
  ];

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  system.defaults = {
    dock.autohide = true;
    dock.tilesize = 48;
    dock.magnification = false;
    dock.persistent-apps = [
      "/Applications/Arc.app"
      "/Applications/Discord.app"
      "/Applications/Ghostty.app"
      "/Applications/Zed.app"
      "/System/Applications/System Settings.app"
    ];

    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";

    trackpad.TrackpadRightClick = true;

    controlcenter.BatteryShowPercentage = true;

    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
  };

  # Enable sudo touch id authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  myModules.system.shell.default = "fish";

  environment.variables = {
    NIX_HOST = "darwin";
  };
}
