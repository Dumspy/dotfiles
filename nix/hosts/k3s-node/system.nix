{
  config,
  pkgs,
  lib,
  me,
  ...
}: {
  system.stateVersion = "24.11";

  imports = [
    ./hardware-configuration.nix
  ];

  myModules.system = {
    k3s.enable = true;
    tailscale.enable = true;
    monitoring.exporters.enable = true;
    openssh = {
      enable = true;
      authorizedKeys = [me.publicKey];
    };
  };

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

  environment.systemPackages = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.k9s
  ];

  environment.variables = {
    KUBECONFIG = "$HOME/.kube/config";
  };

  # Allow Prometheus to scrape node_exporter (port 6443 already opened by k3s module)
  networking.firewall.allowedTCPPorts = [9100];
}
