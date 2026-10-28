{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "26.05";
  imports = [
    ./hardware-configuration.nix
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
    tailscale = {
      enable = true;
      exitNode = true;
    };
    openssh = {
      enable = true;
      tailscaleOnly = true;
      authorizedKeys = [config.var.publicKey];
    };
    shell.default = "zsh";
    deploy.enable = true;
    k3s = {
      enable = true;
      role = "server";
      nodeIp = "10.0.1.215";
      flannelIface = "enp0s6";
      firewallInterfaces = ["enp0s6" "tailscale0"];
      extraFlags = [
        "--tls-san=10.0.1.215"
        "--tls-san=100.64.54.67"
        "--disable=traefik"
        "--write-kubeconfig-mode 0644"
      ];
    };
  };

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  # Networking
  networking.hostName = "oci-node-3";
  networking.domain = "nixossn.nixosvcn.oraclevcn.com";
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
    hashedPassword = "$y$j9T$8R.g9In3C6CZP1FVcRKoM.$5OcjxY6bfsihBD1mlRsirXvzIx0DZkBeQO74V5XCq96";
  };

  # Packages
  environment.systemPackages = with pkgs; [git htop curl k9s gcc gnumake];

  environment.variables = {
    KUBECONFIG = "$HOME/.kube/config";
  };

  # Tailscale direct connections. 41641/tcp is unused.
  # SSH (22) is tailscale0-only. k3s 6443/8472 and tinyproxy 8888 are
  # limited to the VCN NIC and Tailscale.
  networking.firewall.allowedUDPPorts = [41641];
  networking.firewall.interfaces.enp0s6.allowedTCPPorts = [8888];
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [8888];

  # Tinyproxy
  services.tinyproxy = {
    enable = true;
    settings = {
      Listen = "0.0.0.0";
      Port = 8888;
      Allow = ["10.0.1.0/24"];
    };
  };

  # Prevent tinyproxy from restarting during rebuilds
  # to maintain network connectivity for oci-node-1 and oci-node-2
  systemd.services.tinyproxy.restartIfChanged = false;
}
