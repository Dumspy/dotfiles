{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "24.11";

  imports = [
    ./hardware-configuration.nix
    ../../modules/system/k3s.nix
    ../../modules/system/tailscale.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "k3s-node";

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  users.groups = {
    certs = {
      gid = 1001;
    };
  };

  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = ["networkmanager" "wheel" "certs"];
    packages = with pkgs; [];
  };

  services.openssh.enable = true;
  users.users."nixos".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTz½E5AAAAIHuBvk3U7Pdlf5vUV6eH1VvUDigRHDRMp+d+pdo7jTky main-key"
  ];

  environment.systemPackages = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.k9s
  ];

  environment.variables = {
    KUBECONFIG = "$HOME/.kube/config";
  };
}
