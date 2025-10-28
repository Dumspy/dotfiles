{
  config,
  pkgs,
  me,
  ...
}: {
  nix.enable = true;

  system.primaryUser = me.username;

  #homebrew
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "discord"
      "arc"
      "docker"
      "notion"
      "spotify"
      "raycast"
      "zed"
      "visual-studio-code"
      "visual-studio-code@insiders"
      "bruno"
      "dbeaver-community"
      "tailscale"
    ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    brews = [
      "pyenv"
    ];
  };

  #Users
  users.users = {
    "${me.username}" = {
      name = "${me.username}";
      home = "${me.homePrefix}";
    };
  };

  environment.systemPackages = [
    pkgs.dotnetCorePackages.sdk_9_0-bin
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
      "/System/Applications/Launchpad.app"
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
}
