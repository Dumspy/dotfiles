{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "24.11";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/oci-keepalive.nix
  ];

  # Modules
  myModules.system = {
    tailscale.enable = true;
    oci-keepalive = {
      enable = true;
      activeHours = "06-22";
      minLoad = 5;
      maxLoad = 30;
    };
    openssh = {
      enable = true;
      authorizedKeys = [config.var.publicKey];
    };
  };

  # Networking
  networking.hostName = "oci-node-2";
  networking.useDHCP = lib.mkDefault true;

  # Time zone
  time.timeZone = "Europe/Copenhagen";

  # Locale
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

  # User
  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Packages
  environment.systemPackages = with pkgs; [git htop curl];

  # Firewall (Tailscale)
  networking.firewall.allowedTCPPorts = [41641];
  networking.firewall.allowedUDPPorts = [41641];
}
