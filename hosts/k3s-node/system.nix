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
    k3s = {
      enable = true;
      extraFlags = ["--tls-san=100.109.48.72"];
    };
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
  networking.hostName = "k3s-node";

  # Set your time zone.
  # (locale + timezone live in ../common/locale.nix)

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

  users.users."${config.var.username}" = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = [
      "networkmanager"
      "wheel"
      "certs"
    ];
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
