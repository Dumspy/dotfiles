{
  config,
  pkgs,
  me,
  ...
}: {
  services.nix-daemon.enable = true;

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
  nix.configureBuildUsers = true;
  nix.useDaemon = true;

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
  security.pam.enableSudoTouchIdAuth = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # For some reason sops darwin has default keys....
  sops.gnupg.sshKeyPaths = [];
  sops.age.sshKeyPaths = [];
}
