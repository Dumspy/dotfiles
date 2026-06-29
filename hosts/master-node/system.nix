{
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "26.05";

  imports = [
    ./hardware-configuration.nix
    ../common/locale.nix
  ];

  myModules.system = {
    traefik.enable = true;
    tailscale.enable = true;
    openssh = {
      enable = true;
      authorizedKeys = [config.var.publicKey];
    };
    deploy.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "master-node";

  # Set your time zone.
  # (locale + timezone live in ../common/locale.nix)

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  users.users."${config.var.username}" = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment.systemPackages = [
    pkgs.gcc
    pkgs.gnumake
  ];
}
