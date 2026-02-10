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

  # Boot options
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  zramSwap.enable = true;

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
    shell.default = "zsh";
    deploy.enable = true;
  };

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  systemd.services.tailscaled.serviceConfig = {
    Environment = [
      "HTTP_PROXY=http://10.0.1.215:8888"
      "HTTPS_PROXY=http://10.0.1.215:8888"
      "NO_PROXY=localhost,127.0.0.1"
    ];
  };

  # Networking
  networking.hostName = "oci-node-2";
  networking.domain = "nixossn.nixosvcn.oraclevcn.com";
  networking.useDHCP = lib.mkDefault true;

  # Proxy configuration using oci-node-3
  networking.proxy.default = "http://10.0.1.215:8888";
  networking.proxy.noProxy = "localhost,127.0.0.1";

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
    hashedPassword = "$y$j9T$8R.g9In3C6CZP1FVcRKoM.$5OcjxY6bfsihBD1mlRsirXvzIx0DZkBeQO74V5XCq96";
  };

  # Packages
  environment.systemPackages = with pkgs; [git htop curl];

  # Firewall
  networking.firewall.allowedTCPPorts = [22 41641];
  networking.firewall.allowedUDPPorts = [41641];
}
